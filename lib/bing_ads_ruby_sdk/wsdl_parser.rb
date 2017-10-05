module BingAdsRubySdk
  class WSDLParser
    attr_reader :parser, :abstract_types

    def initialize(abstract_types, url)
      # The parser is a convenient way to parse the wsdl using nokogiri.
      @abstract_types = abstract_types
      @parser = LolSoap::WSDLParser.parse(File.read(open(url)))
      return if @abstract_types.nil?
      add_abstract_for_operations
      add_abstract_for_types
    end

    private

    def add_abstract_for_operations
      parser.operations.each do |_name, content|
        content[:input][:body].each do |full_name|
          add_abstract(parser.elements[full_name][:type][:elements])
        end
      end
    end

    def add_abstract_for_types
      parser.types.each do |_full_name, content|
        add_abstract(content[:elements])
      end
    end

    def add_abstract(content)
      content.keys.each do |base|
        next if abstract_types[base].nil?
        # Here the namespace is part of the type full_name
        namespace = content[base][:type].first
        abstract_types[base].each do |concrete|
          elem = parser.elements[[namespace, concrete]]
          # Inject concrete element in types containing the abstract element
          # We use the concrete element name as a key to build the soap body
          # We'll use the abstract element name as the xml node name
          # We'll have to add the attribute "type" later
          content[elem[:name]] = elem.merge(name: base)
        end
      end
    end
  end
end
