require __ORIGINAL__

class Struct
  def as_json(options = nil)
    Hash[members.zip(values)].as_json(options)
  end
end

class String
  def as_json(options = nil) #:nodoc:
    self
  end
end

class Time
  def as_json(options = nil) #:nodoc:
    if ActiveSupport::JSON::Encoding.use_standard_json_time_format
      xmlschema(ActiveSupport::JSON::Encoding.time_precision)
    else
      %(#{strftime("%Y/%m/%d %H:%M:%S")} #{formatted_offset(false)})
    end
  end
end

class Date
  def as_json(options = nil) #:nodoc:
    if ActiveSupport::JSON::Encoding.use_standard_json_time_format
      strftime("%Y-%m-%d")
    else
      strftime("%Y/%m/%d")
    end
  end
end

# class DateTime
#   def as_json(options = nil) #:nodoc:
#     if ActiveSupport::JSON::Encoding.use_standard_json_time_format
#       xmlschema(ActiveSupport::JSON::Encoding.time_precision)
#     else
#       strftime('%Y/%m/%d %H:%M:%S %z')
#     end
#   end
# end
