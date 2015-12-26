MotionBlender.on_require 'active_support/i18n' do
  require 'i18n'

  src = File.expand_path('../../locale/en.yml', __FILE__)
  item = [src, 'locale/active_support/en.yml']
  unless I18n.load_path.include? item
    I18n.load_path << item
  end
end
