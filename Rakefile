# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

if RUBY_PLATFORM == 'java'
  task default: :spec
else
  require 'rubocop/rake_task'
  require 'spellr/rake_task'
  require 'leftovers/rake_task'
  RuboCop::RakeTask.new
  Spellr::RakeTask.generate_task
  Leftovers::RakeTask.generate_task
  task default: [:spec, :rubocop, :spellr, :leftovers]
end
