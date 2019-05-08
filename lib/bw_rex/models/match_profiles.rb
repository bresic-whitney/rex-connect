# frozen_string_literal: true

module BwRex
  class MatchProfiles
    include BwRex::Core::Model

    DEFAULT_CATEGORY = 'residential_sale'
    DEFAULT_PROFILE_NAME = 'BW website'
    CAMPAIGN_FREQUENCY_NEVER = 'never'
    CAMPAIGN_FREQUENCY_DAYLY = 'daily'
    CAMPAIGN_FREQUENCY_WEEKLY = 'weekly'
    CAMPAIGN_FREQUENCY_FORTNIGHTLY = 'fortnightly'
    CAMPAIGN_FREQUENCY_MONTHLY = 'monthly'
    CAMPAIGN_FREQUENCY_DAY_START = 'monday'
    CAMPAIGN_FREQUENCY_HOUR_START = '17:00:00'

    CAMPAIGN_FREQUENCIES = [
      CAMPAIGN_FREQUENCY_DAYLY,
      CAMPAIGN_FREQUENCY_WEEKLY,
      CAMPAIGN_FREQUENCY_FORTNIGHTLY,
      CAMPAIGN_FREQUENCY_MONTHLY
    ].freeze

    action :delete, as: :purge

    action :read do
      field :id, presence: true
    end

    action :find do
      criteria :category, default: DEFAULT_CATEGORY
      criteria :profile_name, default: DEFAULT_PROFILE_NAME
      criteria :contact_id, presence: true

      order_by :system_ctime
    end

    action :create, return_id: true do
      field :category, default: DEFAULT_CATEGORY
      field :profile_name, default: DEFAULT_PROFILE_NAME
      field :contact_id, presence: true

      field :price, as: :price_match, range: true
      field :rent_per_week, as: :est_rent_pw, range: true
      field :bedrooms, as: :attr_bedrooms, range: true
      field :bathrooms, as: :attr_bathrooms, range: true
      field :garages, as: :attr_garages, range: true

      related do
        field :suburbs, default: []
        field :listing_categories, default: []
        field :campaigns, default: []
        field :tags, as: :tags_any, default: []
      end
    end

    action :update, return_id: true do
      field :category, default: DEFAULT_CATEGORY
      field :profile_name, default: DEFAULT_PROFILE_NAME

      field :price, as: :price_match, range: true
      field :rent_per_week, as: :est_rent_pw, range: true
      field :bedrooms, as: :attr_bedrooms, range: true
      field :bathrooms, as: :attr_bathrooms, range: true
      field :garages, as: :attr_garages, range: true

      related do
        field :suburbs, default: []
        field :listing_categories, default: []
        field :campaigns, default: []
        field :tags, as: :tags_any, default: []
      end
    end

    action :listings, as: 'matchAgainstListings' do
      field :id, as: :match_profile_id
    end
  end
end
