# frozen_string_literal: true

module BwRex
  module Core
    module DSL
      class Presenter
        include Core::DSL::Utils

        attr_reader :attributes, :fields, :host

        attr_accessor :options

        def initialize(host)
          @host = host
          @options = {}
          @attributes = []
          @fields = []
        end

        def field(name, options = {})
          proxy = options[:use]
          if proxy && !proxy.included_modules.include?(BwRex::Core::Model)
            raise "The partial presenter '#{proxy}' for the field '#{name}' must include 'BwRex::Core::Model'"
          end

          @fields << pack(name, options)
          @attributes << name.to_sym
        end

        def render(output)
          return output if !output.is_a?(Hash) || fields.empty?

          output = BwRex::Core::NavigableHash[output]

          fields.map.with_object(host.new) do |field, instance|
            instance.send "#{field[:value]}=", extract(field, output)
          end
        end

        private

        def extract(field, output)
          key, options = field.values_at(:name, :options)
          value = output.dig_and_collect(*key.to_s.split('.'))

          options[:use] ? options[:use].render(value) : value
        end
      end
    end
  end
end
