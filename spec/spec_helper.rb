# frozen_string_literal: true

require 'simplecov'
require 'simplecov-rcov'

SimpleCov.start do
  add_filter %r{/support/}
end
SimpleCov.command_name 'Rspec'
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter
]

require 'dotenv'
Dotenv.load('.env')

require 'logger'
require 'webmock/rspec'
require 'bundler/setup'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/time'
require 'bw_rex'

BwLogger = Logger.new(STDOUT)
BwLogger.level = Logger::WARN

BwRex.configure do |configuration|
  configuration.logger = BwLogger
  configuration.endpoint = ENV['REX_ENDPOINT']
  configuration.environment_id = ENV['REX_ENVIRONMENT_ID']
  configuration.email = ENV['REX_USERNAME']
  configuration.password = ENV['REX_PASSWORD']
  configuration.sync_period_in_days = 7

  # TODO: remove
  configuration.custom_type_id = '12841'
  configuration.custom_view_mode_id = '12840'
  configuration.custom_admin_email_id = '12842'
end

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f }

RSpec.configure do |config|
  config.include WebMock::API

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around do |example|
    if example.metadata[:type] == :feature
      WebMock.allow_net_connect!
      example.run # CR.turned_off { example.run }
      WebMock.disable_net_connect!
    else
      example.run
    end
  end
end
