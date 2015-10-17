Module.new do
  def use_bytes_methods
    before do
      bytes_methods = [:kilobytes, :megabytes, :gigabytes, :terabytes]
      bytes_methods.each_with_index do |m, i|
        define_singleton_method(m) { |n| n * 1024 ** (i + 1) }
      end
    end
  end

  Bacon::Context.send :include, self
end
