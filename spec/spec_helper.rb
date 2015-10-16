require 'motion_blender'
require 'i18n'

MotionBlender.raketime do
  file = File.expand_path('../fixtures/locale/ja.yml', __FILE__)
  I18n.load_path << [file, 'locale/spec/ja.yml']

  task 'spec' => 'motive_support:locale:prepare'
end

MotionBlender.runtime do
  I18n.load_path << 'locale/spec/ja.yml'
end
