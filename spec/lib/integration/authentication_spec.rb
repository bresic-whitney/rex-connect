# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::Core::Authentication, type: :feature do
  describe '#login' do
    subject do
      described_class.new(email: config.email,
                          password: config.password,
                          environment_id: config.environment_id).login
    end

    let(:config) { BwRex.configuration }

    it { is_expected.not_to be_nil }
  end
end
