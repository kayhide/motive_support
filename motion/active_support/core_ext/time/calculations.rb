require __ORIGINAL__

class Time
  # def compare_with_coercion(other)
  #   # we're avoiding Time#to_datetime cause it's expensive
  #   if other.is_a?(Time)
  #     compare_without_coercion(other.to_time)
  #   else
  #     to_datetime <=> other
  #   end
  # end
  # alias_method :compare_without_coercion, :<=>
  # alias_method :<=>, :compare_with_coercion
  def compare_with_coercion(other)
    compare_without_coercion(other)
  end
  alias_method :<=>, :compare_with_coercion
end
