require "bundler/gem_tasks"

if (Rake.application.top_level_tasks - Rake.application.tasks.map(&:name)).any?
  $:.unshift("/Library/RubyMotion/lib")
  require 'motion/project/template/ios'
  Bundler.require

  require 'motive_support/all'
  require 'motion-redgreen'
  require 'motion-stump'

  require File.join(Motion::Project::App.config.specs_dir, 'helpers/_init')

  Motion::Project::App.setup do |app|
    app.name = 'MotiveSupport'
    app.redgreen_style = :progress
  end
end
