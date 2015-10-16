require 'motion_blender'
MotionBlender.add
MotionBlender.use_motion_dir

require "motive_support/version"

MotionBlender.raketime do
  require 'motive_support/rake_tasks'
end

MotionBlender.runtime do
  require 'motive_support/callbacks'
  require 'motive_support/concern'
  require 'motive_support/core_ext'
  require 'motive_support/inflector'
  require 'active_support/logger'
  require 'active_support/number_helper'
end

require 'active_support/i18n'
