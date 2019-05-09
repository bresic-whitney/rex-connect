# frozen_string_literal: true

require 'bw_rex/configuration'
require 'bw_rex/core'
require 'bw_rex/models'
require 'bw_rex/sessions'
require 'bw_rex/version'

module BwRex
  class << self
    attr_accessor :token
  end

  def self.version
    VERSION
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.welcome
    raise 'Configuration is missing!' unless @configuration
    raise 'Logger is missing!' unless @configuration.logger

    state = BwRex::HealthCheck.verify ? 'ON' : 'OFF'
    "Rex Server at '#{@configuration.endpoint}' is #{state}".tap do |message|
      @configuration.logger.info message
    end
  end

  def self.configure
    yield(configuration)
  end
end
