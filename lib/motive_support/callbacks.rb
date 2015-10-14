require 'motion_blender'
MotionBlender.add
MotionBlender.use_motion_dir File.expand_path('../../../motion', __FILE__)

require 'active_support/_stdlib/array'
require 'active_support/concern'
require 'active_support/descendants_tracker'
require 'active_support/callbacks'
require 'active_support/core_ext/kernel/singleton_class'
