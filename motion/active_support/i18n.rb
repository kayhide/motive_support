require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/hash/slice'

require 'i18n'
require 'active_support/lazy_load_hooks'

ActiveSupport.run_load_hooks(:i18n)

MotionBlender.raketime do
  I18n.load_path << ["#{File.dirname(__FILE__)}/locale/en.yml", 'locale/active_support/en.yml']
end

MotionBlender.runtime do
  I18n.load_path << 'locale/active_support/en.yml'
end
