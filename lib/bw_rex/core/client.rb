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
        raise 'Configuration not set' unless BwRex.configuration
        @config = BwRex.configuration
        h = { email: @config.email, password: @config.password, environment_id: @config.environment_id }
        @authenticator = Authentication.new(h)
      end

      def post(query)
        new_token(query) unless BwRex.token
        request(query)
      rescue TokenError
        new_token(query)
        post(query)
      end

      def new_token(query = nil)
        return if query == @authenticator.query(:login)
        @authenticator.login.tap { |token| BwRex.token = token }
      end

      private

      def request(body)
        body = body.merge(token: BwRex.token).to_json
        response = HTTParty.post(@config.endpoint, body: body).body
        output = JSON.parse(response)

        raise ServerError, output['error'] if output['error']
        output['result']
      end
    end
  end
end
