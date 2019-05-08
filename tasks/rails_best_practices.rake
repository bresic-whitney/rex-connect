# frozen_string_literal: true

desc 'Verify the code with rails_best_practices'
task :rails_best_practices do
  sh('bundle exec rails_best_practices')
end
