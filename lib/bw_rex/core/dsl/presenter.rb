# frozen_string_literal: true

# implement 'profile' yml config
# map from profile
# use from profile

module BwRex
  module Core
    module DSL
      class Presenter
        include Core::DSL::Utils

        attr_reader :attributes, :fields, :host, :options

        def initialize(host, options = {})
          @host = host
          @options = options
          @attributes = []
          @fields = []
        end

        def field(name, options = {}, &block)
          options[:helper] = block if block

          validate(name, options)

          @fields << pack(name.to_sym, options)
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

        def field?(name)
          attributes.include?(name.to_sym)
        end

        private

        def extract(field, output, opts = {})
          value = generate_value(field, output, opts)

          return unless value
          return value unless field[:options][:use]

          use_options = {}
          use_options[:stub] = field[:options][:use_stub] == true
          use_options[:profile] = field[:options][:use_profile] if field[:options][:use_profile]

          field[:options][:use].render(value, use_options)
        end

        def generate_value(field, output, opts = {})
          keys = generate_keys(field, output, opts)
          options = field[:options]

          value = output.dig_and_collect(*keys)
          value = options[:match] =~ value ? Regexp.last_match(1) : value

          with_helper value, output, options
        end

        def generate_keys(field, output, opts = {})
          key, options = field.values_at(:name, :options)
          key = options[:proc].call(output) if options[:proc].respond_to?(:call)
          keys = key.to_s.split('.')

          stub = options[:stub] == true || opts[:stub] == true
          keys = keys.map { |k| k[0] == '_' ? k : "_#{k}" } if stub

          keys
        end

        def validate(name, options)
          proxy = options[:use]
          message = "The partial presenter '#{proxy}' for the field '#{name}' must include 'BwRex::Core::Model'"
          raise message if proxy && !proxy.included_modules.include?(BwRex::Core::Model)
        end

        def with_helper(value, output, options)
          return value unless options[:helper]

          helper = options[:helper].respond_to?(:call) ? options[:helper] : host.method(options[:helper])
          helper&.call(value, output)
        end
      end
    end
  end
end
