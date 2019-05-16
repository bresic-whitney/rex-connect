# frozen_string_literal: true

module BwRex
  class SetupMatchProfileSession < BwRex::Core::BaseSession
    model MatchProfiles

    attr_accessor :contact_email, :property_type, :frequency, :notes, :current

    def run
      prepare

      self.current = instance.find

      create_or_update.tap do
        create_note
      end
    end

    private

    def prepare
      self.contact_id = Contacts.search_ids_by_email(email: contact_email).min
      self.listing_categories = property_type ? [{ 'value' => listing_category }] : []
      self.campaigns = frequency_valid? ? [campaign] : []
      self.suburbs = suburbs ? suburbs.map { |name| SystemValues.suburb(name) } : []
      self.tags = tags ? tags.map { |tag| { 'value' => tag } } : []
    end

    def create_or_update
      current ? update : create
    end

    def update
      self.id = current['_id']
      self.listing_categories = merge_lists(listing_categories, current.dig('_related', 'listing_categories'), :value)
      self.suburbs = merge_lists(suburbs, current.dig('_related', 'suburbs'), :suburb_or_town)
      self.campaigns = merge_lists(campaigns, current.dig('_related', 'campaigns'), :frequency)
      self.tags = merge_lists(tags, current.dig('_related', 'tags_any'), :value)
      instance.update
    end

    def create_note
      Notes.create(contact_id: contact_id, text: notes) if notes
    end

    def listing_category
      SystemValues.listing_subcat(MatchProfiles::DEFAULT_CATEGORY, property_type)&.fetch('id')
    end

    def frequency_valid?
      MatchProfiles::CAMPAIGN_FREQUENCIES.include?(frequency)
    end

    def campaign
      {
        'campaign_type' => 'email',
        'frequency' => frequency,
        'send_time' => MatchProfiles::CAMPAIGN_FREQUENCY_HOUR_START,
        'send_day' => MatchProfiles::CAMPAIGN_FREQUENCY_DAY_START
      }
    end
  end
end
