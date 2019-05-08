# frozen_string_literal: true

module BwRex
  class PublishedListings
    include BwRex::Core::Model
    as 'PublishedListings'

    SECONDS_PER_DAY = 86_400
    EXTRA_FIELDS = %w[
      images
      floorplans
      meta
      features
      events
      advert_internet
      subcategories
      documents
      tags
      allowances
      links
    ].freeze

    action :read do
      field :id, presence: true
      field :extra_fields, default: []
    end

    action :etags, as: :search do
      field :result_format, value: 'etags'
      field :limit, value: 10_000
      field :offset, value: 0

      criteria :system_modtime, type: '>='
    end

    action :search do
      field :result_format, value: 'website_overrides_applied'
      field :limit, default: 100
      extra_options do
        field :extra_fields, default: []
      end
    end

    action :search_by_ids, as: :search do
      field :result_format, value: 'website_overrides_applied'
      field :limit, default: 100
      extra_options do
        field :extra_fields, default: []
      end
      criteria :ids, as: :id, type: 'in'
    end

    def extra_fields
      @extra_fields ||= EXTRA_FIELDS + custom_fields
    end

    def custom_fields
      %i[type view_mode admin_email].map do |par|
        ['cf', 'listings', BwRex.configuration.send("custom_#{par}_id")].join('.')
      end
    end

    def system_modtime
      Time.now.to_i - (BwRex.configuration.sync_period_in_days.to_i * SECONDS_PER_DAY)
    end
  end
end
