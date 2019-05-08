# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::Properties do
  describe '#create' do
    subject do
      described_class.new(category: { id: '654' }, unit_number: 1, street_number: 35,
                          street_name: 'Some name', suburb: 'Sydney', state: 'NSW',
                          postcode: '2000', bedrooms: 1, bathrooms: 1, garages: 0)
    end

    let(:query) do
      {
        method: 'Properties::create',
        args: {
          data: {
            property_category: { id: '654' },
            adr_unit_number: 1,
            adr_street_number: 35,
            adr_street_name: 'Some name',
            adr_suburb_or_town: 'Sydney',
            adr_state_or_region: 'NSW',
            adr_postcode: '2000',
            adr_country: 'aus',
            attr_bedrooms: 1,
            attr_bathrooms: 1,
            attr_garages: 0
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
