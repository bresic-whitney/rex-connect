# frozen_string_literal: true

module BwRex
  module Core
    module Session
      def model(klazz)
        @model = klazz
      end
    end

    class BaseSession
      extend Session
      include Core::DSL::Utils

      # Sometimes it is easier to access this proxy instance for testing purpouses
      attr_accessor :__proxy_instance

      def initialize(attrs = {})
        @attrs = attrs.clone
        @__proxy_instance = instance

        @attrs.each do |name, val|
          send("#{name}=", val) if respond_to? name
        end
      end

      protected

      def instance(other = {})
        model.new(@attrs.merge(other))
      end

      private

      def model
        self.class.instance_variable_get('@model') || Object
      end

      def method_missing(name, *args, &block)
        return super unless respond_to_missing?(name)

        @attrs[name[0..-2].to_sym] = args[0] if name[-1] == '='
        @__proxy_instance.send(name, *args, &block)
      end

      def respond_to_missing?(name, include_private = false)
        @__proxy_instance.respond_to?(name) || super
      end
    end
  end
end
