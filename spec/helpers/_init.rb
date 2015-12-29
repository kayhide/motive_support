MotionBlender.raketime do
  spec_dir = Motion::Project::App.config.specs_dir
  %w(ja fr).each do |lang|
    src = File.join(spec_dir, "fixtures/locale/#{lang}.yml")
    I18n.load_path << [src, "locale/spec/#{lang}.yml"]
  end
end
