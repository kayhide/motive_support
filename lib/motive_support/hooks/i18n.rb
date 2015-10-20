MotionBlender.on_require 'active_support/i18n' do
  require 'i18n'

  src = File.expand_path('../../locale/en.yml', __FILE__)
  I18n.load_path << [src, 'locale/active_support/en.yml']
end
