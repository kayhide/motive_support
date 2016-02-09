Module.new do
  def unicode_string
    'こんにちは'
  end

  def ascii_string
    'ohayo'
  end

  def byte_string
    "\270\236\010\210\245".force_encoding("ASCII-8BIT")
  end

  Bacon::Context.send :include, self
end
