# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'spellr/rake_task'

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)
Spellr::RakeTask.generate_task

task default: [:spec, :rubocop, :spellr]
