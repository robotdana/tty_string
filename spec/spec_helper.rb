# frozen_string_literal: true

require 'bundler/setup'
if ENV['COVERAGE']
  require 'simplecov'
  require 'simplecov-console'
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.5')
    SimpleCov.enable_coverage :branch
    SimpleCov.minimum_coverage line: 100, branch: 100
  else
    SimpleCov.minimum_coverage line: 100
  end

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ])

  SimpleCov.start
end

require 'tty_string'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
