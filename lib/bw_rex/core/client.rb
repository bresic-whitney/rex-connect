# frozen_string_literal: true

require 'httparty'

module BwRex
  module Core
    class ServerError < StandardError
      attr_accessor :type, :code, :query

      def initialize(rex_error)
        super(rex_error['message'])
        self.type = rex_error['type']
        self.code = rex_error['code']
        self.query = rex_error['query']
      end
    end

    class TokenError
      def self.===(exception)
        exception.is_a?(ServerError) && exception.type == 'TokenException'
      end
    end

    class Client
      def initialize
        @config = BwRex.configuration
        raise 'Configuration not set' unless @config
      end

      def post(query, token = BwRex.token)
        request query, token || new_token(query)
      rescue TokenError
        request query, new_token(query)
      end

      def new_token(query = nil)
        return if @config.multi_user || query == authenticator.query(:login)

        authenticator.login.tap { |token| BwRex.token = token }
      end

      private

      def request(query, token)
        body = query.merge(token: token).to_json
        response = HTTParty.post(@config.endpoint, body: body).body
        output = JSON.parse(response)

        raise ServerError, output['error'] if output['error']

        output['result']
      end

      def authenticator
        @authenticator ||= Authentication.new(default_credentials)
      end

      def default_credentials
        { email: @config.email, password: @config.password, environment_id: @config.environment_id }
      end
    end
  end
end
