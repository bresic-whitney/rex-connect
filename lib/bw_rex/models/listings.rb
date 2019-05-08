# frozen_string_literal: true

module BwRex
  class Listings
    include BwRex::Core::Model

    action :read do
      field :id, presence: true
    end

    action :find_by_alternative_id, as: :search do
      criteria :inbound_unique_id, presence: true
    end

    action :update, return_id: true do
      field :price_advertise_as
      field :price, as: :price_match
    end

    action :create, return_id: true do
      field :property_id, presence: true
      field :listing_category, as: :listing_category_id
      field :agent_1, as: :listing_agent_1_id
      field :agent_2, as: :listing_agent_2_id
      field :price_advertise_as
      field :price, as: :price_match
      field :authority_type_id, value: 'exclusive'
      field :inbound_unique_id
      related do
        field :listing_adverts
        field :listing_images
        field :listing_subcategories
      end
    end
  end
end
