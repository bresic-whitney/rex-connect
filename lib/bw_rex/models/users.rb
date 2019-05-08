# frozen_string_literal: true

module BwRex
  class Users
    include BwRex::Core::Model

    as 'AccountUsers'

    action :find do
      field :result_format, value: 'ids'
      criteria :email, presence: true
    end
  end
end
