# frozen_string_literal: true

module BwRex
  class HealthCheck
    include BwRex::Core::Model

    action :verify, as: 'checkEnvironment'
  end
end
