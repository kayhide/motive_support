require 'rake'
require 'i18n'

namespace :motive_support do
  namespace :locale do
    task :prepare do
      config = Motion::Project::App.config
      resources_dir = Pathname.new(config.resources_dirs.first)
      I18n.load_path.each do |file, name|
        unless name
          dir = $LOAD_PATH.find { |p| file.start_with? p }
          name = File.join('locale', file.sub(/^#{dir}\/?/, ''))
        end
        dst = resources_dir.join(name)
        dst.dirname.mkpath
        Motion::Project::App.info('Copy', file)
        FileUtils.cp file, dst
      end
    end

    task :clean do
      config = Motion::Project::App.config
      resources_dir = Pathname.new(config.resources_dirs.first)
      dir = resources_dir.join('locale')
      if dir.exist?
        Motion::Project::App.info('Delete', dir.to_s)
        dir.rmtree
      end
    end
  end
end

%w(build:simulator build:device).each do |t|
  task t => 'motive_support:locale:prepare'
end

task 'clean' => 'motive_support:locale:clean'
