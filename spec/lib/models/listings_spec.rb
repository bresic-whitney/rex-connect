# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::Listings do
  describe '#read' do
    subject { described_class.new(id: 100) }

    let(:query) do
      {
        method: 'Listings::read',
        args: {
          id: 100
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:read)).to eq(query)
    end
  end

  describe '#update' do
    subject { described_class.new(id: 100, price: 10_000, price_advertise_as: '$10.000') }

    let(:query) do
      {
        method: 'Listings::update',
        args: {
          data: {
            _id: 100,
            price_advertise_as: '$10.000',
            price_match: 10_000
          }
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:update)).to eq(query)
    end
  end

  describe '#create' do
    subject do
      described_class.new(property_id: 1, listing_category: 'residential_sale',
                          price: 10_000, price_advertise_as: '$10.000',
                          agent_1: 76, agent_2: 85)
    end

    let(:query) do
      {
        method: 'Listings::create',
        args: {
          data: {
            property_id: 1,
            listing_category_id: 'residential_sale',
            listing_agent_1_id: 76,
            listing_agent_2_id: 85,
            price_advertise_as: '$10.000',
            price_match: 10_000,
            authority_type_id: 'exclusive'
          },
          return_id: true
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:create)).to eq(query)
    end
  end
end
