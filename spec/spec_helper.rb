MotionBlender.raketime do
  %w(ja fr).each do |lang|
    file = File.expand_path("../fixtures/locale/#{lang}.yml", __FILE__)
    I18n.load_path << [file, "locale/spec/#{lang}.yml"]
  end
end

MotionBlender.runtime do
  %w(ja fr).each do |lang|
    I18n.load_path << "locale/spec/#{lang}.yml"
  end
end
