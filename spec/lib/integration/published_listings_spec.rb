# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::PublishedListings, type: :feature do
  describe '#etags' do
    subject { described_class.etags }

    let(:current_time) { Time.now }

    let(:timestamps) do
      subject.map { |value| value['etag'].split('-').last }
    end

    before do
      allow(Time).to receive(:now).and_return(current_time)
    end

    it 'has only new etags' do
      sync_period_in_seconds = 7 * 86_400
      system_time = current_time.to_i - sync_period_in_seconds

      timestamps.each do |timestamp|
        expect(timestamp.to_i).to be >= system_time
      end
    end
  end

  describe '#listings_for_ids' do
    let(:etags) { described_class.etags }

    let(:listings) { described_class.search_by_ids(ids: ids) }

    let(:ids) { [rex_id] }

    let(:listing) { listings.first }

    context 'when retrieving first and last etags' do
      subject { listings.size }

      let(:ids) do
        [etags.first['_id'], etags.last['_id']]
      end

      it { is_expected.to eq ids.size }

      context 'when first listing matches' do
        subject { listings.first['_id'] }

        it { is_expected.to eq ids.first }
      end
    end

    describe 'Contract test!' do
      let(:rex_id) { find_or_create_listing(:bw_residential) }

      it 'matches base fields' do
        expect(listing.keys).to match_array(listing_fields)
      end

      # TODO: missing fields: allowances (only rent)
      %i[features tags subcategories].each do |key|
        it "contains '#{key}' as array" do
          expect(listing[key.to_s]).not_to be_empty
        end
      end

      # TODO: missing fields: account, location contract allowances
      %w[attributes address listing_agent meta advert_internet image floorplan event link].each do |obj|
        it "contains '#{obj}' as complex object" do
          nodes = listing.keys.grep(/^#{obj}/).flat_map do |key|
            listing[key].is_a?(Hash) ? [listing[key]] : listing[key]
          end

          expect(nodes).not_to be_empty

          nodes.each do |hash|
            expect(hash.keys).to match_array(listing_fields(obj))
          end
        end
      end
    end
  end
end
