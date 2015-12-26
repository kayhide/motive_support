require 'motion_blender'
MotionBlender.incept
MotionBlender.use_motion_dir

require 'motive_support/version'
require 'motive_support/rake_tasks'
require 'motive_support/hooks'

require 'motive_support/ext'


require 'active_support/core_ext/object/acts_like'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/duplicable'
require 'active_support/core_ext/object/deep_dup'
require 'active_support/core_ext/object/itself'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/object/inclusion'

require 'active_support/core_ext/object/conversions'
require 'active_support/core_ext/object/instance_variables'

require 'active_support/core_ext/object/json'
require 'active_support/core_ext/object/to_param'
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/object/with_options'
