require 'motion_blender'
MotionBlender.incept
MotionBlender.use_motion_dir

require 'motive_support/version'
require 'motive_support/rake_tasks'
require 'motive_support/hooks'

require 'motive_support/ext'
require 'active_support/core_ext/string/access'
require 'active_support/core_ext/string/behavior'
require 'active_support/core_ext/string/exclude'
require 'active_support/core_ext/string/filters'
require 'active_support/core_ext/string/indent'
require 'active_support/core_ext/string/starts_ends_with'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/string/strip'
require 'active_support/core_ext/module/delegation'
