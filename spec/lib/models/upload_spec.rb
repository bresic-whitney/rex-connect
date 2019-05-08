# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::Upload do
  describe '#listing_image' do
    subject { described_class.new(url: 'some-url') }

    let(:query) do
      {
        method: 'Upload::uploadListingImage',
        args: {
          url: 'some-url'
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:listing_image)).to eq(query)
    end
  end
end
