require 'time'

class Time
  def to_date
    Date.new(year, month, day)
  end
  
  def to_time
    self
  end
  
  def ==(other)
    other &&
    year == other.year &&
    month == other.month &&
    day == other.day &&
    hour == other.hour &&
    min == other.min &&
    sec == other.sec
  end

  def xmlschema(fraction_digits=0)
    fraction_digits = fraction_digits.to_i
    s = strftime("%FT%T")
    if fraction_digits > 0
      s << strftime(".%#{fraction_digits}N")
    end
    s << (utc? ? 'Z' : strftime("%z").insert(3, ':'))
  end
  alias iso8601 xmlschema
end
