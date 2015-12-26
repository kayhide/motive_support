Module.new do
  def sorted_json json
    return json unless json =~ /^\{.*\}$/
    '{' + json[1..-2].split(',').sort.join(',') + '}'
  end

  def object_keys(json_object)
    json_object[1..-2].scan(/([^{}:,\s]+):/).flatten.sort
  end

  def with_standard_json_time_format(boolean = true)
    old, ActiveSupport.use_standard_json_time_format = ActiveSupport.use_standard_json_time_format, boolean
    yield
  ensure
    ActiveSupport.use_standard_json_time_format = old
  end

  def with_time_precision(value)
    old_value = ActiveSupport::JSON::Encoding.time_precision
    ActiveSupport::JSON::Encoding.time_precision = value
    yield
  ensure
    ActiveSupport::JSON::Encoding.time_precision = old_value
  end

  Bacon::Context.send :include, self
end
