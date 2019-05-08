# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::MatchProfiles do
  describe '#delete' do
    subject { described_class.new(id: '10') }

    let(:query) do
      {
        method: 'MatchProfiles::purge',
        args: {
          id: '10'
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:delete)).to eq(query)
    end
  end

  describe '#read' do
    subject { described_class.new(id: '10') }

    let(:query) do
      {
        method: 'MatchProfiles::read',
        args: {
          id: '10'
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:read)).to eq(query)
    end
  end

  describe '#find' do
    context 'with default values' do
      subject { described_class.new(contact_id: '999') }

      let(:query) do
        {
          method: 'MatchProfiles::search',
          args: {
            limit: 1,
            offset: 0,
            criteria: [{
              name: 'category',
              type: '=',
              value: 'residential_sale'
            }, {
              name: 'profile_name',
              type: '=',
              value: 'BW website'
            }, {
              name: 'contact_id',
              type: '=',
              value: '999'
            }],
            order_by: {
              system_ctime: 'ASC'
            }
          }
        }
      end

      it 'produces the appropriate query' do
        expect(subject.query(:find)).to eq(query)
      end
    end

    context 'with custom values' do
      subject { described_class.new(contact_id: '999', category: 'some_category', profile_name: 'Some Name') }

      let(:query) do
        {
          method: 'MatchProfiles::search',
          args: {
            limit: 1,
            offset: 0,
            criteria: [{
              name: 'category',
              type: '=',
              value: 'some_category'
            }, {
              name: 'profile_name',
              type: '=',
              value: 'Some Name'
            }, {
              name: 'contact_id',
              type: '=',
              value: '999'
            }],
            order_by: {
              system_ctime: 'ASC'
            }
          }
        }
      end

      it 'produces the appropriate query' do
        expect(subject.query(:find)).to eq(query)
      end
    end
  end

  describe '#create' do
    subject do
      described_class.new.tap do |instance|
        instance.contact_id = '999'
        instance.price = [10_000_000, 20_000_000]
        instance.rent_per_week = [500, 700]
        instance.bedrooms = [1, 2]
        instance.bathrooms = [3, 4]
        instance.garages = [5, 6]
        instance.tags = ['modern']
        instance.suburbs = [{ suburb_or_city: 'Sydney', postcode: 2000 }]
        instance.listing_categories = [{ id: '400', text: 'Unit' }]
        instance.campaigns = [{ frequency: 'daily' }]
      end
    end

    let(:query) do
      {
        method: 'MatchProfiles::create',
        args: {
          data: {
            category: 'residential_sale',
            profile_name: 'BW website',
            contact_id: '999',
            price_match: { min: 10_000_000, max: 20_000_000 },
            est_rent_pw: { min: 500, max: 700 },
            attr_bedrooms: { min: 1, max: 2 },
            attr_bathrooms: { min: 3, max: 4 },
            attr_garages: { min: 5, max: 6 },
            _related: {
              suburbs: [{ suburb_or_city: 'Sydney', postcode: 2000 }],
              listing_categories: [{ id: '400', text: 'Unit' }],
              campaigns: [{ frequency: 'daily' }],
              tags_any: ['modern']
            }
          },
          return_id: true
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:create)).to eq(query)
    end
  end

  describe '#update' do
    subject do
      described_class.new.tap do |instance|
        instance.id = '20'
        instance.price = [10_000_000, 20_000_000]
        instance.rent_per_week = [500, 700]
        instance.bedrooms = [1, 2]
        instance.bathrooms = [3, 4]
        instance.garages = [5, 6]
        instance.tags = ['modern']
        instance.suburbs = [{ suburb_or_city: 'Sydney', postcode: 2000 }]
        instance.listing_categories = [{ id: '400', text: 'Unit' }]
        instance.campaigns = [{ frequency: 'daily' }]
      end
    end

    let(:query) do
      {
        method: 'MatchProfiles::update',
        args: {
          data: {
            _id: '20',
            category: 'residential_sale',
            profile_name: 'BW website',
            price_match: { min: 10_000_000, max: 20_000_000 },
            est_rent_pw: { min: 500, max: 700 },
            attr_bedrooms: { min: 1, max: 2 },
            attr_bathrooms: { min: 3, max: 4 },
            attr_garages: { min: 5, max: 6 },
            _related: {
              suburbs: [{ suburb_or_city: 'Sydney', postcode: 2000 }],
              listing_categories: [{ id: '400', text: 'Unit' }],
              campaigns: [{ frequency: 'daily' }],
              tags_any: ['modern']
            }
          }
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:update)).to eq(query)
    end
  end

  describe '#listings' do
    subject { described_class.new(id: '10') }

    let(:query) do
      {
        method: 'MatchProfiles::matchAgainstListings',
        args: {
          match_profile_id: '10'
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:listings)).to eq(query)
    end
  end
end
