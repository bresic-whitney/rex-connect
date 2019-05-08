# frozen_string_literal: true

module BwRex
  class ListingPublication
    include BwRex::Core::Model

    action :publish do
      field :listing_id, presence: true
    end

    action :set_channels, as: 'setActivePublicationChannels' do
      field :listing_id, presence: true
      field :channels, default: %w[automatch external]
    end
  end
end
