class DateTime
  def self.parse str
    fail TypeError, "no implicit conversion of #{str.class} into String" unless str.is_a?(String)
    fail ArgumentError, "invalid date"
  end
end
