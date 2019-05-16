# frozen_string_literal: true

module BwRex
  module Core
    class Authentication
      include Core::Model

      action :login do
        field :email, presence: true
        field :password, presence: true
        field :environment_id, as: :account_id, presence: true
        field :application, value: 'rex'
      end

      action :logout
    end
  end
end
