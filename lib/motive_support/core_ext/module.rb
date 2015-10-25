require 'motion_blender'
MotionBlender.incept
MotionBlender.use_motion_dir

require 'motive_support/version'
require 'motive_support/rake_tasks'
require 'motive_support/hooks'

require 'motive_support/ext'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/module/introspection'
require 'active_support/core_ext/module/anonymous'
require 'active_support/core_ext/module/reachable'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/module/attr_internal'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/module/remove_method'
