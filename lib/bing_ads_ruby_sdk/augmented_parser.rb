# frozen_string_literal: true

module BingAdsRubySdk
  class AugmentedParser
    def initialize(wsdl_file_path)
      @lolsoap_parser = LolSoap::WSDLParser.parse(File.read(wsdl_file_path))
      @concrete_abstract_mapping = {}
    end

    def call
      add_subtypes_to_definitions

      [lolsoap_parser, concrete_abstract_mapping]
    end

    private

    attr_reader :lolsoap_parser, :concrete_abstract_mapping

    # adds subtypes to existing definitions.
    # for instance, the wsdl specifies AdExtensionAssociation are accepted for AddAdExtension
    # but there is no way to specify the type we want
    # the goal is to:
    # - validate properly the attributes
    # - ensure the attributes are properly formatted when xml is created
    # - ensure we inject proper type to the xml
    def add_subtypes_to_definitions
      # to augment all types definitions
      lolsoap_parser.types.each_value do |content|
        add_subtypes(content[:elements])
      end
      # we have to augment operations because some Requests are abstract, for instance:
      # ReportRequest which can be AccountPerformanceReportRequest etc...
      lolsoap_parser.operations.each_value do |content|
        content[:input][:body].each do |full_name|
          add_subtypes(lolsoap_parser.elements[full_name][:type][:elements])
        end
      end
      @grouped_subtypes = nil # we can reset this as its not needed anymore
    end

    def add_subtypes(content)
      content.keys.each do |base|
        grouped_subtypes.fetch(base, []).each do |sub_type|
          elem = lolsoap_parser.elements[sub_type.id]
          elem[:base_type_name] = base
          content[sub_type.name] = elem
        end
      end
    end

    def grouped_subtypes
      @grouped_subtypes ||= begin
        grouped_types = {}
        # types are defined there: https://github.com/loco2/lolsoap/blob/master/lib/lolsoap/wsdl_parser.rb#L305
        lolsoap_parser.each_node('xs:complexType[not(@abstract="true")]') do |node, schema|
          type = ::LolSoap::WSDLParser::Type.new(lolsoap_parser, schema, node)
          next unless type.base_type # it has a base_type, its a subtype

          base_type = extract_base_type(type.base_type)
          concrete_abstract_mapping[type.name] = base_type.name
          grouped_types[base_type.name] ||= []
          grouped_types[base_type.name].push(type)
        end
        grouped_types
      end
    end

    # we want the real base: sometimes there are many layers of inheritance
    def extract_base_type(type)
      if type.base_type
        extract_base_type(type.base_type)
      else
        type
      end
    end
  end
end
