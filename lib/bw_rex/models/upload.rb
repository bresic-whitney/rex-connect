# frozen_string_literal: true

module BwRex
  class Upload
    include BwRex::Core::Model

    action :listing_image, as: 'uploadListingImage' do
      field :url, presence: true
    end
  end
end
