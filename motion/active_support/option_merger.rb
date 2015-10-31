require 'active_support/core_ext/hash/deep_merge'

module ActiveSupport
  # Inherits from BasicObject avoiding undefs.
  class OptionMerger < BasicObject
    def initialize(context, options)
      @context, @options = context, options
    end

    private

    def method_missing(method, *arguments, &block)
      if arguments.first.is_a?(::Proc)
        proc = arguments.pop
        arguments << ::Kernel.lambda { |*args| @options.deep_merge(proc.call(*args)) }
      else
        arguments << (arguments.last.respond_to?(:to_hash) ?
                        @options.deep_merge(arguments.pop) : @options.dup)
      end

      @context.__send__(method, *arguments, &block)
    end
  end
end
