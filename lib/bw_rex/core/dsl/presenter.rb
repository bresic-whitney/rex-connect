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

        def field(name, options = {}, &block)
          validate(name, options)
          options[:dyna] = block
          @fields << pack(name, options)
          @attributes |= [name.to_sym]
        end

        def render(output, options = {})
          return output if !output.is_a?(Hash) || fields.empty?

          puts JSON.pretty_generate(output) if debug?
          output = BwRex::Core::NavigableHash[output]

          model = host.new
          model.id = output['id'] || output['_id']

          fields.map.with_object(model) do |field, instance|
            value = extract(field, output, options)
            instance.send("#{field[:value]}=", value) if value
          end
        end

        def debug?
          @options[:debug] == true
        end

        private

        def extract(field, output, opts = {})
          value = generate_value(field, output, opts)

          return unless value
          return value unless field[:options][:use]

          use_options = { stub: field[:options][:stub] == true }
          field[:options][:use].render(value, use_options)
        end

        def generate_value(field, output, opts = {})
          keys = generate_keys(field, output, opts)

          options = field[:options]
          value = output.dig_and_collect(*keys)
          value = options[:match] =~ value ? Regexp.last_match(1) : value
          value = options[:dyna].call(value, output) if options[:dyna].respond_to?(:call)
          value
        end

        def generate_keys(field, output, opts = {})
          key, options = field.values_at(:name, :options)
          key = options[:proc].call(output) if options[:proc].respond_to?(:call)
          keys = key.to_s.split('.')
          keys = keys.map { |k| "_#{k}" } if options[:stub] == true || opts[:stub] == true
          keys
        end

        def validate(name, options)
          proxy = options[:use]
          message = "The partial presenter '#{proxy}' for the field '#{name}' must include 'BwRex::Core::Model'"
          raise message if proxy && !proxy.included_modules.include?(BwRex::Core::Model)
        end
      end
    end
  end
end
