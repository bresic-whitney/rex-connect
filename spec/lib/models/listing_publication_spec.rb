# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::ListingPublication do
  describe '#publish' do
    subject { described_class.new(listing_id: 100) }

    let(:query) do
      {
        method: 'ListingPublication::publish',
        args: {
          listing_id: 100
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:publish)).to eq(query)
    end
  end

  describe '#set_channels' do
    subject { described_class.new(listing_id: 100) }

    context 'with default channels' do
      let(:query) do
        {
          method: 'ListingPublication::setActivePublicationChannels',
          args: {
            listing_id: 100,
            channels: %w[automatch external]
          }
        }
      end

      it 'produces the appropriate query' do
        expect(subject.query(:set_channels)).to eq(query)
      end
    end

    context 'with custom channels' do
      let(:query) do
        {
          method: 'ListingPublication::setActivePublicationChannels',
          args: {
            listing_id: 100,
            channels: ['test']
          }
        }
      end

      it 'produces the appropriate query' do
        subject.channels = ['test']
        expect(subject.query(:set_channels)).to eq(query)
      end
    end
  end
end
