# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::PublishNewListingSession do
  describe '#run' do
    subject do
      described_class.new(property_data).tap do |subject|
        subject.listing = listing
        subject.custom_fields_map = custom_fields_map
      end
    end

    let(:listing) { BwRex::Listings.new(listing_category: 'residential_sale') }

    let(:custom_fields_map) do
      { '100' => 'Off Market',
        '101' => 'Preview',
        '102' => 'admin@email.com' }
    end

    let(:property_data) do
      {
        street_number: 109,
        street_name: 'Elisaberh Street',
        suburb: 'Sydney',
        state: 'NSW',
        postcode: '2000',
        bedrooms: 1,
        bathrooms: 1,
        garages: 0
      }
    end

    before do
      allow(subject.__proxy_instance).to receive(:create).and_return(10)
      allow(listing).to receive(:create).and_return(20)
      allow(BwRex::SystemValues)
        .to receive(:listing_subcat)
        .with('residential_sale', 'Unit')
        .and_return('id' => '546')
      allow(BwRex::Upload).to receive(:listing_image).with(url: '/images/test.jpg')
      allow(BwRex::CustomFields).to receive(:set).with(id: 20, value_map: custom_fields_map)
      allow(BwRex::ListingPublication).to receive(:set_channels).with(listing_id: 20)
      allow(BwRex::ListingPublication).to receive(:publish).with(listing_id: 20)
    end

    it 'calls the appropriate services' do
      subject.listing_advert(body: 'some text')
      subject.listing_image('/images/test.jpg')
      subject.listing_subcategory('Unit')
      subject.run

      expect(subject.id).to be(10)
      expect(subject.listing.property_id).to be(10)
      expect(subject.listing.id).to be(20)
    end
  end
end
