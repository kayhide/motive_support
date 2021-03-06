# Handles JSON encoding and decoding in a similar way Ruby 1.9 does.
module JSON

  class ParserError < StandardError; end

  # Parses a string or data object and converts it in data structure.
  #
  # @param [String, NSData] str_data the string or data to serialize.
  # @raise [ParserError] If the parsing of the passed string/data isn't valid.
  # @return [Hash, Array, NilClass] the converted data structure, nil if the incoming string isn't valid.
  #
  # TODO: support options like the C Ruby module does
  def self.parse(str_data, *args, &block)
    return nil unless str_data
    data = str_data.respond_to?('dataUsingEncoding:') ? str_data.dataUsingEncoding(NSUTF8StringEncoding) : str_data
    opts = NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
    error = Pointer.new(:id)
    obj = NSJSONSerialization.JSONObjectWithData(data, options:opts, error:error)
    raise ParserError, error[0].description if error[0]
    if block_given?
      yield obj
    else
      obj
    end

  end

  def self.generate(obj, *args)
    if obj.is_a?(Array) || obj.is_a?(Hash)
      NSJSONSerialization.dataWithJSONObject(obj, options:0, error:nil).to_s
    else
      NSJSONSerialization.dataWithJSONObject([obj], options:0, error:nil).to_s[1..-2]
    end.gsub(/\\\\u|\\\//, '\\\\u' => '\\u', '\/' => '/')
  end

  class State
  end
end

# Preparations for core_ext/object/json
[Enumerable, Object, Array, FalseClass, Float, Hash, Integer, NilClass, String, TrueClass].each do |klass|
  klass.class_eval do
    def to_json(options = nil)
    end
  end
end
