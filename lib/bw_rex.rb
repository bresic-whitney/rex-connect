# frozen_string_literal: true

require 'bw_rex/configuration'
require 'bw_rex/core'
require 'bw_rex/models'
require 'bw_rex/sessions'
require 'bw_rex/version'

module BwRex
  class << self
    attr_accessor :token

    def welcome
      raise 'Configuration is missing!' unless @configuration
      raise 'Logger is missing!' unless @configuration.logger

      state = BwRex::HealthCheck.verify ? 'ON' : 'OFF'
      "Rex Server at '#{@configuration.endpoint}' is #{state}".tap do |message|
        @configuration.logger.info message
      end
    end

    def initialize(namespaces = [])
      filter = ->(c) { namespaces.empty? || !(c.name.split('::') & namespaces).empty? }
      models.select(&filter).each(&method(:add_profiles)) if @configuration.profiles.is_a?(Hash)
    end

    private

    def models
      ObjectSpace.each_object(Class).to_a.select do |c|
        c.included_modules.include?(BwRex::Core::Model)
      end
    end

    def add_profiles(model)
      key = profile_key(model)
      return unless @configuration.profiles.key?(key)

      @configuration.profiles[key].each do |profile_name, profile_fields|
        model.map(profile: profile_name.to_sym) do
          profile_fields.each do |name, as|
            field(name, as: as) unless field?(name)
          end
        end
      end
    end

    def profile_key(model)
      key = model.name.split('::').last
      key = key.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      key = key.gsub(/([a-z\d])([A-Z])/, '\1_\2')
      key = key.tr('-', '_').downcase
      key.to_sym
    end
  end

  def self.version
    VERSION
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
