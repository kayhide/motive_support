require 'motion_blender'
MotionBlender.add
MotionBlender.use_motion_dir File.expand_path('../../../../motion', __FILE__)

require 'cgi'
require 'active_support/core_ext/object/acts_like'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/deep_dup'
require 'active_support/core_ext/object/duplicable'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/object/inclusion'
require 'active_support/core_ext/object/instance_variables'
require 'active_support/core_ext/object/to_param'
require 'active_support/core_ext/object/to_query'
