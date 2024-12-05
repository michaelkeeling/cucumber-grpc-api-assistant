# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'grpc-api-assistant/version'

Gem::Specification.new do |spec|
  spec.name = 'cucumber-grpc-api-assistant'
  spec.version = GrpcApiAssistant::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors = ['Garrett Cramer', 'Eric Kaun', 'Michael Keeling', 'Michael Lipschultz']
  spec.email = ['mkeeling@neverletdown.net']

  spec.summary = 'A set of Cucumber steps for testing gRPC services'
  spec.description = 'A set of Cucumber steps for testing gRPC services.'
  spec.homepage = 'https://github.com/michaelkeeling/cucumber-grpc-api-assistant'

  spec.files = `git ls-files`.split("\n")
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.2.0'
  spec.license = 'MIT'

  spec.add_dependency('grpc', '~> 1.52')
  spec.add_dependency('grpc-tools', '~> 1.51')
  spec.add_dependency('net-ssh', '~> 7.0')

  spec.add_dependency('cucumber', '~> 9.2')
  spec.add_dependency('rspec-expectations', '~> 3.12')

  spec.add_development_dependency('pry', '~> 0.14')
  spec.add_development_dependency('pry-byebug', '~> 3.10')
  spec.add_development_dependency('rake', '~> 13.0')
end
