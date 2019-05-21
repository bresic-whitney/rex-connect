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

        def render(output)
          return output if !output.is_a?(Hash) || fields.empty?

          puts JSON.pretty_generate(output) if debug?
          output = BwRex::Core::NavigableHash[output]

          model = host.new
          model.id = output['id'] || output['_id']

          fields.map.with_object(model) do |field, instance|
            value = extract(field, output)
            instance.send("#{field[:value]}=", value) if value
          end
        end

        def debug?
          @options[:debug] == true
        end

        private

        def extract(field, output)
          key, options = field.values_at(:name, :options)
          key = options[:proc].call(output) if options[:proc].respond_to?(:call)

          value = output.dig_and_collect(*key.to_s.split('.'))
          value = options[:match] =~ value ? Regexp.last_match(1) : value
          value = options[:dyna].call(value, output) if options[:dyna].respond_to?(:call)

          return unless value

          options[:use] ? options[:use].render(value) : value
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
