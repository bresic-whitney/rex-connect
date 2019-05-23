# frozen_string_literal: true

class Configuration
  attr_accessor :logger,
                :endpoint,
                :email,
                :password,
                :environment_id,
                :multi_user

  def initialize
    self.logger = nil

    self.endpoint = nil
    self.email = nil
    self.password = nil
    self.environment_id = nil

    self.multi_user = false
  end
end
