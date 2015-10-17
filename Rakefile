$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require "bundler/gem_tasks"
Bundler.require

require File.join(Motion::Project::App.config.specs_dir, 'spec_helper')

Motion::Project::App.setup do |app|
  app.name = 'MotiveSupport'
end
