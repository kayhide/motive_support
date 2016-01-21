require 'motion_blender/interpreters/base'

module MotiveSupport
  module Interpreters
    class AutoloadBlockInterpreter < MotionBlender::Interpreters::Base
      class << self
        def requirable? source
          source.type.block? &&
            source.children[0] &&
            source.children[0].method == method
        end
      end

      def interpret *args, &proc
        object.extend ActiveSupport::Autoload
        object.send method, *args, &proc
      end

      class AtInterpreter < self
        interprets :autoload_at
      end

      class UnderInterpreter < self
        interprets :autoload_under
      end
    end
  end
end
