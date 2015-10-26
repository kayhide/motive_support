require 'active_support/core_ext/object/blank'

module ActiveSupport
  module XmlMini_NSXMLParser
    extend self

    def parse(data)
      if data.respond_to?(:read)
        data = data.read
      end

      if data.blank?
        {}
      else
        data = data.dataUsingEncoding(NSUTF8StringEncoding)
        parser = NSXMLParser.alloc.initWithData(data)
        parser.delegate = XMLParserDelegate.new
        parser.parse
        parser.delegate.hash
      end
    end

    def xml_str
      xml = <<EOM
<items>
  <item id="123">
    <name>Andy</name>
    <age>21</age>
  </item>
  <item id="234">
    <name>Brian</name>
    <age>23</age>
  </item>
  <item id="345">
    <name>Charles</name>
    <age>19</age>
  </item>
</items>
EOM
    end

    def xml_str2
      "<users><count>2</count><timestamp>2014/11/10 19:20:21.123</timestamp><user><name>Taro</name></user><user><name>Hanako</name></user></users>"
    end

    class XMLParserDelegate
      CONTENT_KEY   = '__content__'.freeze
      HASH_SIZE_KEY = '__hash_size__'.freeze

      attr_reader :hash

      def current_hash
        @hash_stack.last
      end

      def parserDidStartDocument(parser)
        @hash = {}
        @hash_stack = [@hash]
      end

      def parserDidEndDocument(parser)
        raise "Parse stack not empty!" if @hash_stack.size > 1
      end

      def parser(parser, didStartElement: name, namespaceURI: _, qualifiedName: _, attributes: attrs)
        new_hash = { CONTENT_KEY => '' }.merge!(Hash[attrs])
        new_hash[HASH_SIZE_KEY] = new_hash.size + 1

        case current_hash[name]
          when Array then current_hash[name] << new_hash
          when Hash  then current_hash[name] = [current_hash[name], new_hash]
          when nil   then current_hash[name] = new_hash
        end

        @hash_stack.push(new_hash)
      end

      def parser(parser, didEndElement: name, namespaceURI: _, qualifiedName: _)
        if current_hash.length > current_hash.delete(HASH_SIZE_KEY) && current_hash[CONTENT_KEY].blank?
          current_hash.delete(CONTENT_KEY)
        end
        @hash_stack.pop
      end

      def parser(parser, foundCharacters: string)
        current_hash[CONTENT_KEY] << string
      end
    end
  end
end
