require 'motion_blender/interpreters/autoload_interpreter'

module MotiveSupport
  module Interpreters
    class AutoloadInterpreter < MotionBlender::Interpreters::AutoloadInterpreter
      interprets :autoload, receiver: Module

      def interpret const_name, path = nil
        if path
          super const_name, path.sub(/^#<.+?>\//, '')
        else
          object.extend ActiveSupport::Autoload
          object.autoload const_name, path
        end
      end
    end
  end
end
