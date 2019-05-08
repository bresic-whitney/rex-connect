# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::Duplications do
  describe '#combine' do
    subject { described_class.new(winning_id: 100, losing_ids: [10, 20]) }

    let(:query) do
      {
        method: 'Dedupe::combineRecords',
        args: {
          service_name: 'Contacts',
          winning_id: 100,
          losing_ids: [10, 20]
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:combine)).to eq(query)
    end
  end
end
