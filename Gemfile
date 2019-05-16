# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in bw-rex.gemspec
gemspec

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv'
  gem 'fuubar'
end

group :development do
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  gem 'webmock'
end
