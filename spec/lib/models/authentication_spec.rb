# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::Core::Authentication do
  describe '#login' do
    subject { described_class.new(email: 'some@email.com', password: 'some-password', environment_id: 400) }

    let(:query) do
      {
        method: 'Authentication::login',
        args: {
          email: 'some@email.com',
          password: 'some-password',
          account_id: 400,
          application: 'rex'
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:login)).to eq(query)
    end
  end
end
