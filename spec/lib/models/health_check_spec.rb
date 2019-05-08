# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::HealthCheck do
  describe '#verify' do
    subject { described_class.new }

    let(:query) do
      {
        method: 'HealthCheck::checkEnvironment',
        args: {}
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:verify)).to eq(query)
    end
  end
end
