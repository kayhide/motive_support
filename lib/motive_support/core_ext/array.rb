require 'motion_blender'
MotionBlender.incept
MotionBlender.use_motion_dir

require 'motive_support/version'
require 'motive_support/rake_tasks'
require 'motive_support/hooks'

require 'motive_support/ext'
require 'active_support/core_ext/array'
require 'active_support/core_ext/array/wrap'
require 'active_support/core_ext/array/access'
require 'active_support/core_ext/array/conversions'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/array/grouping'
require 'active_support/core_ext/array/prepend_and_append'
