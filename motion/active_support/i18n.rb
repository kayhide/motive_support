require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/hash/slice'

require 'i18n'

resource_dir = NSBundle.mainBundle.resourcePath
Dir.chdir resource_dir do
  I18n.load_path.concat Dir['locale/**/*.yml']
end
