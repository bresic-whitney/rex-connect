# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

import 'tasks/rubocop.rake'

RSpec::Core::RakeTask.new(:spec)

task :default do
  Rake::Task['rubocop'].invoke
  Rake::Task['spec'].invoke
end
