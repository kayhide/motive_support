require 'motion_blender'
MotionBlender.incept
MotionBlender.use_motion_dir

require 'motive_support/version'
require 'motive_support/rake_tasks'
require 'motive_support/hooks'

require 'motive_support/ext'
require 'motive_support/time'
require 'motive_support/core_ext'

require 'motive_support/callbacks'
require 'motive_support/concern'
require 'motive_support/inflector'

require 'active_support/logger'
require 'active_support/number_helper'
require 'active_support/i18n'
