# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

import 'tasks/rubocop.rake'
import 'tasks/rails_best_practices.rake'

RSpec::Core::RakeTask.new(:spec)

task :default do
  Rake::Task['rubocop'].invoke
  Rake::Task['rails_best_practices'].invoke
  Rake::Task['spec'].invoke
end
