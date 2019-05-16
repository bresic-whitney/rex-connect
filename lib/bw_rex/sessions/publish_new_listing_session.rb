# frozen_string_literal: true

module BwRex
  class PublishNewListingSession < BwRex::Core::BaseSession
    model Properties

    attr_accessor :listing, :listing_type, :view_mode, :admin_email

    def run
      create_property
      create_listing
      set_custom_fields
      set_active_channels
      publish_listing

      listing_id
    end

    def listing_advert(type: 'internet', heading: 'Internet head line', body: '')
      listing.listing_adverts = [{ 'advert_type' => type, 'advert_heading' => heading, 'advert_body' => body }]
    end

    def listing_image(url)
      listing.listing_images = [BwRex::Upload.listing_image(url: url)]
    end

    def listing_subcategory(property_type)
      subcategory = SystemValues.listing_subcat(listing.listing_category, property_type)&.fetch('id')
      listing.listing_subcategories = [{ 'priority' => 1, subcategory: { id: subcategory } }]
    end

    private

    def listing_id
      listing.id
    end

    def create_property
      self.category = { id: 'residential' }
      self.id ||= create
    end

    def create_listing
      listing.property_id = self.id
      listing.id = listing.create
    end

    def set_custom_fields
      return if custom_fields_map.values.compact.empty?

      BwRex::CustomFields.set(id: listing_id, value_map: custom_fields_map)
    end

    def set_active_channels
      BwRex::ListingPublication.set_channels(listing_id: listing_id)
    end

    def publish_listing
      BwRex::ListingPublication.publish(listing_id: listing_id)
    end

    def custom_fields_map
      conf = BwRex.configuration

      { conf.custom_type_id => custom_type_value,
        conf.custom_view_mode_id => custom_view_mode_value,
        conf.custom_admin_email_id => admin_email }
    end

    def custom_type_value
      { on_market: 'On Market', off_market: 'Off Market' }.fetch(listing_type, nil)
    end

    def custom_view_mode_value
      { preview: 'Preview', live: 'Live' }.fetch(view_mode, nil)
    end
  end
end
