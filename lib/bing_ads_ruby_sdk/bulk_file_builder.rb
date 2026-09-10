# frozen_string_literal: true

require "csv"

module BingAdsRubySdk
  class BulkFileBuilder
    DEFAULT_FORMAT_VERSION = "6.0"

    def initialize(format_version: DEFAULT_FORMAT_VERSION, delimiter: ",")
      @delimiter = delimiter
      @records = [{"Type" => "Format Version", "Name" => format_version}]
    end

    def add_record(type, attributes = {})
      @records << {"Type" => type.to_s}.merge(stringify_keys(attributes))
      self
    end

    def add_campaign(name:, status: "Paused", campaign_type: "Search", budget: 1, budget_type: "DailyBudgetStandard", time_zone: "RomanceStandardTime", client_id: nil)
      attributes = {
        "Status" => status,
        "Campaign" => name,
        "Campaign Type" => campaign_type,
        "Budget" => budget,
        "Budget Type" => budget_type,
        "Time Zone" => time_zone
      }
      attributes["Client Id"] = client_id if client_id
      add_record("Campaign", attributes)
    end

    def to_s
      columns = @records.each_with_object([]) do |record, result|
        record.keys.each { |key| result << key unless result.include?(key) }
      end

      CSV.generate(col_sep: @delimiter) do |csv|
        csv << columns
        @records.each { |record| csv << columns.map { |column| record[column] } }
      end.prepend("\uFEFF")
    end

    private

    def stringify_keys(attributes)
      attributes.each_with_object({}) do |(key, value), result|
        result[key.to_s] = value
      end
    end
  end
end
