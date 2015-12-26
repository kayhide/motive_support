require __ORIGINAL__

module ActiveSupport
  module JSON
    module Encoding
      class JSONGemEncoder

        # Added #as_json
        class EscapedString < String
          def as_json(*)
            if Encoding.escape_html_entities_in_json
              super.gsub ESCAPE_REGEX_WITH_HTML_ENTITIES, ESCAPED_CHARS
            else
              super.gsub ESCAPE_REGEX_WITHOUT_HTML_ENTITIES, ESCAPED_CHARS
            end
          end
        end

        # Overwrite original
        # Use EscapedString#as_json for String
        def jsonify(value)
          case value
          when String
            EscapedString.new(value).as_json
          when Numeric, NilClass, TrueClass, FalseClass
            value
          when Hash
            Hash[value.map { |k, v| [jsonify(k), jsonify(v)] }]
          when Array
            value.map { |v| jsonify(v) }
          else
            jsonify value.as_json
          end
        end
      end
    end
  end
end
