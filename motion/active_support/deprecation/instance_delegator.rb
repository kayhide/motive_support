require 'active_support/core_ext/kernel/singleton_class'
require 'active_support/core_ext/module/delegation'
require 'active_support/concern'

module ActiveSupport
  class Deprecation
    module InstanceDelegator # :nodoc:
      extend Concern

      included do |base|
        base.public_class_method :new

        class << base
          def include included_module
            included_module.instance_methods(false).each { |m| method_added(m) }
            super
          end

          def method_added(method_name)
            singleton_class.delegate(method_name, to: :instance)
          end
        end
      end
    end
  end
end
