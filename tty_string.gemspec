# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tty_string/version'

Gem::Specification.new do |spec|
  spec.name = 'tty_string'
  spec.version = TTYString::VERSION
  spec.authors = ['Dana Sherson']
  spec.email = ['robot@dana.sh']

  spec.summary = 'Render a string using ANSI TTY codes'
  spec.homepage = 'https://github.com/robotdana/tty_string'
  spec.license = 'MIT'

  spec.files = Dir.glob('{lib}/**/*') + %w{
    CHANGELOG.md
    Gemfile
    LICENSE.txt
    README.md
    tty_string.gemspec
  }
  spec.required_ruby_version = '>= 2.4'
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.74'
  spec.add_development_dependency 'rubocop-performance', '~> 1.4'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.35'
  spec.add_development_dependency 'simplecov', '~> 0.18.5'
end
