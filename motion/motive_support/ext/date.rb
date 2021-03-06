class Date
  MONTHNAMES = [nil, *%w(January February March April May June July August September October November December)]
  ABBR_MONTHNAMES = [nil, *%w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)]
  DAYNAMES = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
  ABBR_DAYNAMES = %w(Sun Mon Tue Wed Thu Fri Sat)

  def self.parse str
    fail TypeError, "no implicit conversion of #{str.class} into String" unless str.is_a?(String)
    formatter = NSDateFormatter.new
    ["yyyy-MM-dd", "yyyyMMdd"].each do |format|
      formatter.dateFormat = format
      str = str.slice(0, format.length).gsub(/[\/\.]/, '-')
      t = formatter.dateFromString(str)
      return Date.new(t.year, t.month, t.day) if t
    end
    fail ArgumentError, "invalid date"
  end

  # rough implementation, the original is:
  # http://rxr.whitequark.org/mri/source/ext/date/date_parse.c
  def self._parse str, comp = true
    res = {}

    t = str.match(/(?<=\D|\A)(\d+):(\d+)(?::(\d+)(?:\.(\d+)|)|)(?=\D|\Z)/) # HH:MM:SS.sss
    if t
      res[:hour] = t[1].to_i
      res[:min] = t[2].to_i
      res[:sec] = t[3].to_i if t[3]
      res[:sec_fraction] = Rational(t[4].to_i, 10**t[4].length) if t[4]

      z = str[t.end(0)..-1].match(/([-+]\d{1,2}):?(\d{2})(?::?(\d{2})|)(?=\D|\Z)/) # [-+]zz:zz:zz
      if z
        res[:zone] = z[0]
        res[:offset] = z[1].to_i * 3600 + z[2].to_i * 60 + z[3].to_i
      end
      str = str[0...t.begin(0)]
    end

    mon = ABBR_MONTHNAMES.drop(1).join('|')
    if d = str.match(/(\d+)\s+(#{mon})(?:\s+(\d+)|)(?=\D|\Z)/) # dd Mon yyyy | yyyy Mon dd
      res[:mon] = ABBR_MONTHNAMES.index(d[2])
      res[(d[1].length > 2) ? :year : :mday] = d[1].to_i
      res[res.key?(:mday) ? :year : :mday] = d[3].to_i if d[3]
    elsif d = str.match(/(#{mon})(?:\s+(\d+)|)(?:\s+(\d+)|)(?=\D|\Z)/) # Mon dd yyyy
      res[:mon] = ABBR_MONTHNAMES.index(d[1])
      res[(d[2].length > 2) ? :year : :mday] = d[2].to_i if d[2]
      res[res.key?(:mday) ? :year : :mday] = d[3].to_i if d[3]
    else
      d ||= str.match(/(\d+)\/(\d+)(?:\/(\d+)|)(?=\D|\Z)/) # yyyy/mm/dd
      d ||= str.match(/(\d+)\.(\d+)(?:\.(\d+)|)(?=\D|\Z)/) # yyyy.mm.dd
      d ||= str.match(/(\d+)-(\d+)(?:-(\d+)|)(?=\D|\Z)/) # yyyy-mm-dd
      d ||= str.match(/(\d{4}|\d{2}|)(\d{2})(\d{1,2})(?=\D|\Z)/) # yyyymmdd
      if d
        res[:year] = d[1].to_i if d[1]
        res[:mon] = d[2].to_i if d[2]
        res[:mday] = d[3].to_i if d[3]
      end
    end
    if comp && res.key?(:year) && res[:year] < 100
      res[:year] += (res[:year] < 69) ? 2000 : 1000
    end
    res
  end

  def self.gregorian_leap?(year)
    if year % 400 == 0
      true
    elsif year % 100 == 0 then
      false
    elsif year % 4 == 0 then
      true
    else
      false
    end
  end

  def initialize(year = nil, month = nil, day = nil)
    if year && month && day
      @value = Time.utc(year, month, day)
    else
      @value = Time.now
    end
  end

  def self.today
    new
  end

  def to_s
    "#{year}-#{month}-#{day}"
  end

  def ==(other)
    year == other.year &&
    month == other.month &&
    day == other.day
  end

  def +(other)
    val = @value + other * 3600 * 24
    Date.new(val.year, val.month, val.day)
  end

  def -(other)
    if other.is_a?(Date)
      (@value - other.instance_variable_get(:@value)) / (3600 * 24)
    elsif other.is_a?(Time)
      (@value - other)
    else
      self + (-other)
    end
  end

  def >>(months)
    new_year = year + (self.month + months - 1) / 12
    new_month = (self.month + months) % 12
    new_month = new_month == 0 ? 12 : new_month
    new_day = [day, Time.days_in_month(new_month, new_year)].min

    Date.new(new_year, new_month, new_day)
  end

  def <<(months)
    return self >> -months
  end

  [:year, :month, :day, :wday, :<, :<=, :>, :>=, :"<=>", :strftime].each do |method|
    define_method method do |*args|
      @value.send(method, *args)
    end
  end

  def to_date
    self
  end

  def to_time
    @value
  end

  def succ
    self + 1
  end

  def gregorian?
    true
  end

  def julian?
    false
  end
end
