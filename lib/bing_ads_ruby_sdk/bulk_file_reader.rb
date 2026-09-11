# frozen_string_literal: true

require "csv"
require "fiddle"
require "stringio"
require "tempfile"
require "zlib"
require "zip"

module BingAdsRubySdk
  class BulkFileReader
    class ProcessMetrics
      RUSAGE_SELF = 0
      MAX_RSS_OFFSET = 32

      class << self
        def max_rss_bytes
          pointer = Fiddle::Pointer.malloc(256)
          return nil unless getrusage.call(RUSAGE_SELF, pointer).zero?

          value = pointer[MAX_RSS_OFFSET, 8].unpack1("q")
          RUBY_PLATFORM.include?("darwin") ? value : value * 1024
        rescue
          nil
        end

        private

        def getrusage
          @getrusage ||= Fiddle::Function.new(
            Fiddle::Handle::DEFAULT["getrusage"],
            [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP],
            Fiddle::TYPE_INT
          )
        end
      end
    end

    class CountingIO
      attr_reader :bytes_read

      def initialize(io)
        @io = io
        @bytes_read = 0
        @first_value = true
      end

      def gets(*args)
        count(@io.gets(*args))
      end

      def read(*args)
        count(@io.read(*args))
      end

      def eof?
        @io.eof?
      end

      def close
        @io.close
      end

      private

      def count(value)
        @bytes_read += value.bytesize if value
        value.force_encoding(Encoding::UTF_8) if value && value.encoding != Encoding::UTF_8
        if value && @first_value
          @first_value = false
          value = value.delete_prefix("\uFEFF")
        end
        value
      end
    end

    ZIP_SIGNATURE = "PK\x03\x04".b
    GZIP_SIGNATURE = "\x1F\x8B".b
    REPORT_METADATA = /\A"?(?:Report Name|Report Time|Time Zone|Last Completed|Report Aggregation|Report Filter|Potential Incomplete Data|Rows):/

    def initialize(content, instrumentation: nil)
      @content = content
      @instrumentation = instrumentation
    end

    def to_csv
      measure(:to_csv) do
        if streamed_content?
          streamed_to_csv
        else
          content = csv_content
          if !report_file?(content)
            CSV.parse(content, headers: true)
          else
            parser = CSV.new(content, headers: false)
            headers = nil
            data_rows = []

            parser.each do |row|
              if headers
                data_rows << CSV::Row.new(headers, row)
              elsif report_header?(row)
                headers = row
              end
            end

            if headers
              CSV::Table.new(data_rows)
            else
              CSV.parse(content, headers: true)
            end
          end
        end
      end
    end

    def each_row
      return enum_for(__method__) unless block_given?

      measure(:each_row) do
        if streamed_content?
          Tempfile.create("bing-ads-bulk") do |file|
            content.each { |chunk| file.write(chunk) }
            file.flush
            file.rewind
            each_row_from_file(file) { |row| yield row }
          end
        else
          each_row_from_parser(CSV.new(csv_content, headers: false)) { |row| yield row }
        end
      end

      self
    end

    private

    attr_reader :content

    def measure(operation)
      return yield unless instrumentation_registered?

      wall_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      cpu_start = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
      rss_before = ProcessMetrics.max_rss_bytes
      completed = false

      result = yield
      completed = true
      result
    ensure
      if instrumentation_registered?
        rss_after = ProcessMetrics.max_rss_bytes
        emit_metrics(
          operation: operation,
          success: completed,
          wall_time_seconds: Process.clock_gettime(Process::CLOCK_MONOTONIC) - wall_start,
          cpu_time_seconds: Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID) - cpu_start,
          rss_max_bytes_before: rss_before,
          rss_max_bytes_after: rss_after,
          rss_max_bytes_delta: rss_delta(rss_before, rss_after),
          compression: @instrumentation_compression,
          input_bytes: @instrumentation_input_bytes,
          output_bytes: @instrumentation_output_bytes,
          duration_ms: ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - wall_start) * 1000).round(3),
          error_class: completed ? nil : $!.class.name
        )
      end
    end

    def with_intrumentation(event:, compression:, input_bytes:, output_bytes: nil, duration_ms: nil, success: true)
      unless instrumentation_registered?
        return yield if block_given?
        return nil
      end

      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      output = nil
      completed = success.nil? ? nil : false

      begin
        output = yield if block_given?
        completed = true if !success.nil?
        output
      ensure
        emit_event(
          event: event,
          compression: compression,
          input_bytes: input_bytes,
          output_bytes: output_bytes || (output.respond_to?(:bytesize) ? output.bytesize : output),
          duration_ms: duration_ms || ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round(3),
          success: success.nil? ? nil : completed,
          error_class: (completed == false) ? $!.class.name : nil
        )
      end
    end

    def emit_event(event)
      instrumentation&.call(event)
    rescue
      nil
    end

    def emit_metrics(metrics)
      instrumentation&.call(metrics)
    rescue
      nil
    end

    def rss_delta(before, after)
      return nil unless before && after

      [after - before, 0].max
    end

    attr_reader :instrumentation

    def instrumentation_registered?
      !instrumentation.nil?
    end

    def streamed_content?
      !content.is_a?(String)
    end

    def streamed_to_csv
      rows = []
      each_row { |row| rows << row }
      CSV::Table.new(rows)
    end

    def each_row_from_file(file)
      signature = file.read(4)
      file.rewind
      compression = if signature == ZIP_SIGNATURE
        :zip
      elsif signature.start_with?(GZIP_SIGNATURE)
        :gzip
      else
        :none
      end
      input_bytes = file.size
      @instrumentation_compression = compression
      @instrumentation_input_bytes = input_bytes
      output_bytes = nil
      extracted_file = nil

      if compression == :zip
        _, output_bytes = decode_zip_stream(file, compression: compression, input_bytes: input_bytes) do |extracted_file|
          each_row_from_parser(CSV.new(extracted_file, headers: false)) { |row| yield row }
        end
      elsif compression == :gzip
        _, output_bytes = decode_gzip_stream(file, compression: compression, input_bytes: input_bytes) do |gzip_source|
          each_row_from_parser(CSV.new(gzip_source, headers: false)) { |row| yield row }
        end
      else
        each_row_from_parser(CSV.new(file, headers: false)) { |row| yield row }
        output_bytes = input_bytes
      end
    ensure
      @instrumentation_output_bytes = output_bytes
      with_intrumentation(event: :decode_finish, compression: compression, input_bytes: input_bytes) do
        output_bytes
      end
      extracted_file&.close!
    end

    def each_row_from_parser(parser)
      headers = nil
      report = false

      parser.each do |row|
        row[0] = row[0].delete_prefix("\uFEFF") if row.first

        if headers
          yield CSV::Row.new(headers, row)
        elsif row.first.to_s.match?(REPORT_METADATA)
          report = true
        elsif !report || report_header?(row)
          headers = row
        end
      end
    end

    def report_file?(csv)
      REPORT_METADATA.match?(csv)
    end

    def report_header?(row)
      row.compact.length > 1 && !row.first.to_s.match?(REPORT_METADATA)
    end

    def csv_content
      compression = compression_type
      input_bytes = content.bytesize
      @instrumentation_compression = compression
      @instrumentation_input_bytes = input_bytes
      with_intrumentation(
        event: :decode_start,
        compression: compression,
        input_bytes: input_bytes,
        output_bytes: nil,
        duration_ms: nil,
        success: nil
      ) do
        nil
      end

      decoded = with_intrumentation(event: :decode_finish, compression: compression, input_bytes: input_bytes) do
        decoded = case compression
        when :zip
          decode_zip_content
        when :gzip
          decode_gzip_content
        else
          content
        end

        decoded = decoded.dup.force_encoding(Encoding::UTF_8) unless decoded.encoding == Encoding::UTF_8
        decoded = decoded.delete_prefix("\uFEFF")
        @instrumentation_output_bytes = decoded.bytesize
        decoded
      end

      decoded
    ensure
      @instrumentation_output_bytes ||= decoded&.bytesize
    end

    def compression_type
      return :zip if zip_signature?
      return :gzip if gzip_signature?

      :none
    end

    def zip_signature?
      content.getbyte(0) == 0x50 && content.getbyte(1) == 0x4B &&
        content.getbyte(2) == 0x03 && content.getbyte(3) == 0x04
    end

    def gzip_signature?
      content.getbyte(0) == 0x1F && content.getbyte(1) == 0x8B
    end

    def decode_zip_stream(file, compression:, input_bytes:)
      extracted_file = nil
      output_bytes = with_intrumentation(event: :unzip_finish, compression: compression, input_bytes: input_bytes) do
        Zip::File.open(file.path) do |archive|
          entry = archive.find { |candidate| !candidate.directory? }
          raise "Bulk archive does not contain a file" unless entry

          extracted_file = Tempfile.new("bing-ads-unzipped")
          IO.copy_stream(entry.get_input_stream, extracted_file)
          extracted_file.flush
          extracted_file.rewind
          extracted_file.set_encoding(Encoding::UTF_8)
          extracted_file.size
        end
      end

      source = CountingIO.new(extracted_file)
      yield source
      [source, output_bytes]
    end

    def decode_gzip_stream(file, compression:, input_bytes:)
      gzip = Zlib::GzipReader.new(file)
      source = CountingIO.new(gzip)
      output_bytes = with_intrumentation(event: :gunzip_finish, compression: compression, input_bytes: input_bytes) do
        yield source
        source.bytes_read
      ensure
        gzip.close
      end

      [source, output_bytes]
    end

    def decode_zip_content
      with_intrumentation(event: :unzip_finish, compression: compression_type, input_bytes: content.bytesize) do
        extracted = nil
        Zip::File.open_buffer(content) do |archive|
          entry = archive.find { |candidate| !candidate.directory? }
          raise "Bulk archive does not contain a file" unless entry

          extracted = entry.get_input_stream.read(entry.size)
        end
        extracted
      end
    end

    def decode_gzip_content
      with_intrumentation(event: :gunzip_finish, compression: compression_type, input_bytes: content.bytesize) do
        Zlib::GzipReader.new(StringIO.new(content)).read
      end
    end
  end
end
