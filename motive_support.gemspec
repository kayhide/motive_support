# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'motive_support/version'

Gem::Specification.new do |spec|
  spec.name          = 'motive_support'
  spec.version       = MotiveSupport::VERSION
  spec.authors       = ['kayhide']
  spec.email         = ['kayhide@gmail.com']

  spec.summary       = 'ActiveSupport for RubyMotion.'
  spec.description   = 'ActiveSupport for RubyMotion. Directly importing original implementations using MotionBlender.'
  spec.homepage      = 'https://github.com/kayhide/motive_support'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'motion_blender'
  spec.add_runtime_dependency 'activesupport', '= 4.2.5'
  spec.add_runtime_dependency 'motion-yaml', '= 1.5'
  spec.add_runtime_dependency 'motion-securerandom'
  spec.add_runtime_dependency 'i18n', '~> 0.7'
  spec.add_runtime_dependency 'builder', '~> 3.2'
  spec.add_runtime_dependency 'tzinfo', '~> 1.2'
  spec.add_runtime_dependency 'tzinfo-data', '~> 1.2'
  spec.add_development_dependency 'bundler', '>= 1.10'
  spec.add_development_dependency 'rake', '>= 10.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-doc'
  spec.add_development_dependency 'motion-redgreen'
  spec.add_development_dependency 'motion-stump'
end
