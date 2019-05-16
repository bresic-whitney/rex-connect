# frozen_string_literal: true

module BwRex
  module Core
    module Model
      extend Core::DSL::Utils

      module ModelInstanceMethods
        def initialize(hash = nil)
          self.token = hash[:token] if hash.is_a?(Hash) && hash.key?(:token)
          super
        end
      end

      def self.included(base)
        base.extend(DSL::ClassMethods)
        base.include(DSL::InstanceMethods)
        base.include(ModelInstanceMethods)
      end

      attr_accessor :token

      def request(query)
        response = nil
        start_time = Time.now.utc

        log(:debug, 'Sending REX request', request: query.dup, uri: BwRex.configuration.endpoint)

        begin
          response = Client.new.post(query, token || BwRex.token)
          log(:debug, 'Received REX response', response: response)
        rescue StandardError => e
          log(:error, 'Received error from REX', error: e.message)
          raise e
        end

        log(:info, "Processed REX call '[#{query[:method]}]'", duration: Time.now.utc - start_time)

        response
      end

      def log(level, msg, **args)
        return unless BwRex.configuration.logger.send("#{level}?")

        args[:request][:args] = {} if args.dig(:request, :method) == 'Authentication::login'
        payload = { component: 'Rex', class_name: self.class.name }.merge(msg: msg, **args)
        BwRex.configuration.logger.send(level, payload)
      end
    end
  end
end
