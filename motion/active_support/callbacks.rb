require __ORIGINAL__

module ActiveSupport
  module Callbacks
    class Callback #:nodoc:#
      private

      # Overwrite original
      # Drop support of Strings avoiding string eval
      def make_lambda(filter)
        case filter
        when Symbol
          lambda { |target, _, &blk| target.send filter, &blk }
        when Conditionals::Value then filter
        when ::Proc
          if filter.arity > 1
            return lambda { |target, _, &block|
              raise ArgumentError unless block
              target.instance_exec(target, block, &filter)
            }
          end

          if filter.arity <= 0
            lambda { |target, _| target.instance_exec(&filter) }
          else
            lambda { |target, _| target.instance_exec(target, &filter) }
          end
        else
          scopes = Array(chain_config[:scope])
          method_to_call = scopes.map{ |s| public_send(s) }.join("_")

          lambda { |target, _, &blk|
            filter.public_send method_to_call, target, &blk
          }
        end
      end
    end

    module ClassMethods

      # Overwrite original
      # Rewrite not to use string eval
      def define_callbacks(*names)
        options = names.extract_options!

        names.each do |name|
          class_attribute "_#{name}_callbacks"
          set_callbacks name, CallbackChain.new(name, options)

          define_method "_run_#{name}_callbacks" do |&block|
            __run_callbacks__(send("_#{name}_callbacks"), &block)
          end
        end
      end
    end
  end
end
