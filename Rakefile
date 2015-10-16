$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require "bundler/gem_tasks"
Bundler.require

$:.unshift(File.expand_path('../spec', __FILE__))
require 'spec_helper'

Motion::Project::App.setup do |app|
  app.name = 'MotiveSupport'
end
