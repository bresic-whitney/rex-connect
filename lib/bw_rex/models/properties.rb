# frozen_string_literal: true

module BwRex
  class Properties
    include BwRex::Core::Model

    action :read do
      field :id, presence: true
    end

    action :create, return_id: true do
      field :category, as: :property_category, key: :id
      field :unit_number, as: :adr_unit_number
      field :street_number, as: :adr_street_number
      field :street_name, as: :adr_street_name
      field :suburb, as: :adr_suburb_or_town
      field :state, as: :adr_state_or_region
      field :postcode, as: :adr_postcode
      field :country, as: :adr_country, default: 'aus'
      field :bedrooms, as: :attr_bedrooms
      field :bathrooms, as: :attr_bathrooms
      field :garages, as: :attr_garages
    end
  end
end
