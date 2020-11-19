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

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = spec.homepage
    spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  end

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
  spec.add_development_dependency 'fast_ignore', '>= 0.15.1'
  spec.add_development_dependency 'leftovers', '>= 0.2.0'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.93.1'
  spec.add_development_dependency 'rubocop-performance', '~> 1.8.1'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.44.1'
  spec.add_development_dependency 'simplecov', '~> 0.18.5'
  spec.add_development_dependency 'simplecov-console'
  spec.add_development_dependency 'spellr', '>= 0.8.1'
end
