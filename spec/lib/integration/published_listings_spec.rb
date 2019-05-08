# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::PublishedListings, type: :feature do
  describe '#etags' do
    subject { described_class.etags }

    let(:current_time) { Time.current }

    let(:timestamps) do
      subject.map { |value| value['etag'].split('-').last }
    end

    before do
      allow(Time).to receive(:now).and_return(current_time)
    end

    it 'has only new etags' do
      sync_period_in_seconds = BwRex.configuration.sync_period_in_days * 86_400
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

    let(:listing_custom_fields) { listing['custom_fields']['listings'] }

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

    context 'with custom field listing type' do
      subject { listing_custom_fields[BwRex.configuration.custom_type_id] }

      let(:ids) { [rex_id] }
      let(:listing) { listings.first }
      let(:listing_custom_fields) { listing['custom_fields']['listings'] }

      context 'with Off Market' do
        let(:rex_id) { find_or_create_listing(:bw_residential_off_market) }

        it { is_expected.to eq 'Off Market' }
      end

      context 'with On Market' do
        let(:rex_id) { find_or_create_listing(:bw_residential_on_market) }

        it { is_expected.to eq 'On Market' }
      end

      context 'with no value' do
        let(:rex_id) { find_or_create_listing(:bw_residential_no_fields) }

        it { is_expected.to be_nil }
      end
    end

    context 'with custom field view mode' do
      subject { listing_custom_fields[BwRex.configuration.custom_view_mode_id] }

      let(:ids) { [rex_id] }
      let(:listing) { listings.first }
      let(:listing_custom_fields) { listing['custom_fields']['listings'] }

      context 'with Preview' do
        let(:rex_id) { find_or_create_listing(:bw_residential_preview) }

        it { is_expected.to eq 'Preview' }
      end

      context 'with Live' do
        let(:rex_id) { find_or_create_listing(:bw_residential_live) }

        it { is_expected.to eq 'Live' }
      end

      context 'with no value' do
        let(:rex_id) { find_or_create_listing(:bw_residential_no_fields) }

        it { is_expected.to be_nil }
      end
    end

    context 'with custom field admin email' do
      subject { listing_custom_fields[BwRex.configuration.custom_admin_email_id] }

      context 'with email' do
        let(:rex_id) { find_or_create_listing(:bw_residential_preview) }

        it { is_expected.to eq 'integration@test.com' }
      end

      context 'with no value' do
        let(:rex_id) { find_or_create_listing(:bw_residential_no_fields) }

        it { is_expected.to be_nil }
      end
    end

    describe 'Contract test!' do
      let(:rex_id) { find_or_create_listing(:bw_residential) }

      it 'matches base fields' do
        expect(listing.keys).to match_array(listing_fields)
      end

      it 'matches custom fields' do
        custom_fields = %i[custom_type_id custom_view_mode_id custom_admin_email_id].map do |f|
                          BwRex.configuration.send(f)
                        end
        expect(listing.dig('custom_fields', 'listings').keys).to match_array(custom_fields)
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
