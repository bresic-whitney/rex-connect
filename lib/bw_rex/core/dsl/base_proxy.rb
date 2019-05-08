# frozen_string_literal: true

module BwRex
  module Core
    module DSL
      class BaseProxy
        include Core::DSL::Utils

        attr_reader :action_name, :model_name, :attributes, :fields

        def initialize(name, options = {})
          @options = options
          @action_name = options[:as] || name
          @attributes = []
          @fields = Hash.new { |h, k| h[k] = [] }
          @model_name = @options[:model]

          raise "Model name required for action '#{name}'" unless @model_name
        end

        def field(name, options = {})
          register name, @fields[:base], options
        end

        def related(&block)
          with_node_fields(block) do |name, options|
            register name, @fields[:_related], options
          end
        end

        def extra_options(&block)
          with_node_fields(block) do |name, options|
            register name, @fields[:extra_options], options
          end
        end

        def query(instance)
          { method: method_name, args: args(instance) }
        end

        def method_name
          "#{model_name}::#{action_name}"
        end

        def respond(obj)
          obj
        end

        protected

        def args(instance)
          unpack_all(@fields[:base], instance).tap do |args|
            %i[_related extra_options].each do |sub_node|
              unpack_all(@fields[sub_node], instance).tap do |sub_fields|
                args[sub_node] = sub_fields unless sub_fields.empty?
              end
            end
          end
        end

        def with_node_fields(block)
          node = Node.new
          node.instance_eval(&block) if block_given?
          node.fields.each { |name, options| yield name, options }
        end

        def register(name, list, options)
          list << pack(name, options)
          return if options[:value]

          attributes << name.to_sym
          %i[min max].each { |dim| attributes << "#{name}_#{dim}".to_sym } if options[:range]
        end
      end
    end
  end
end
