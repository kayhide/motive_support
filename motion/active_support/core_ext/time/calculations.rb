require __ORIGINAL__

class Time
  # Overwrite original
  # to_datetime does not work
  def compare_with_coercion(other)
    if other.is_a?(Time)
      compare_without_coercion(other.to_time)
    else
      self <=> other.to_time
    end
  end
  alias_method :<=>, :compare_with_coercion
end
