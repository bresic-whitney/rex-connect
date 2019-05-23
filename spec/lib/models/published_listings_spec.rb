# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::PublishedListings do
  subject { described_class.new(ids: [1, 2, 3]) }

  describe '#etags' do
    let(:current_time) { Time.now.to_i }

    let(:timestamp) do
      seconds = 7 * 86_400
      current_time.to_i - seconds
    end

    let(:query) do
      {
        method: 'PublishedListings::search',
        args: {
          result_format: 'etags',
          limit: 10_000,
          offset: 0,
          criteria: [{
            name: 'system_modtime',
            type: '>=',
            value: timestamp
          }]
        }
      }
    end

    before do
      allow(Time).to receive(:now).and_return(current_time)
    end

    it 'produces the appropriate query' do
      expect(subject.query(:etags)).to eq(query)
    end
  end

  describe '#search' do
    let(:query) do
      {
        method: 'PublishedListings::search',
        args: {
          result_format: 'website_overrides_applied',
          limit: 100,
          # criteria: [],
          extra_options: {
            extra_fields: %w[
              images floorplans meta features events advert_internet
              subcategories documents tags allowances links
            ]
          }
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:search)).to eq(query)
    end
  end

  describe '#search_by_ids' do
    let(:query) do
      {
        method: 'PublishedListings::search',
        args: {
          result_format: 'website_overrides_applied',
          limit: 100,
          criteria: [{
            name: 'id',
            type: 'in',
            value: [1, 2, 3]
          }],
          extra_options: {
            extra_fields: %w[
              images floorplans meta features events advert_internet
              subcategories documents tags allowances links
            ]
          }
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:search_by_ids)).to eq(query)
    end
  end
end
