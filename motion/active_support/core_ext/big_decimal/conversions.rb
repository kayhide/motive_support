require __ORIGINAL__

class BigDecimal
  # Overwrite original
  # calling super with args
  def to_formatted_s(*args)
    if args[0].is_a?(Symbol)
      super(*args)
    else
      format = args[0] || DEFAULT_STRING_FORMAT
      _original_to_s(format)
    end
  end
end
