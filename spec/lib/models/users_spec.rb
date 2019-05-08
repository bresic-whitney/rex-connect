# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::Users do
  describe '#find' do
    subject { described_class.new(email: 'some@email.com') }

    let(:query) do
      {
        method: 'AccountUsers::search',
        args: {
          limit: 1,
          offset: 0,
          result_format: 'ids',
          criteria: [{
            name: 'email',
            type: '=',
            value: 'some@email.com'
          }]
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:find)).to eq(query)
    end
  end
end
