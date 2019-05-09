# frozen_string_literal: true

class Configuration
  attr_accessor :logger,
                :endpoint,
                :email,
                :password,
                :environment_id,
                :multi_user,
                :sync_period_in_days,
                :custom_type_id,
                :custom_view_mode_id,
                :custom_admin_email_id

  def initialize
    self.logger = nil

    self.endpoint = nil
    self.email = nil
    self.password = nil
    self.environment_id = nil

    self.multi_user = false

    self.sync_period_in_days = nil
    self.custom_type_id = nil
    self.custom_view_mode_id = nil
    self.custom_admin_email_id = nil
  end
end
