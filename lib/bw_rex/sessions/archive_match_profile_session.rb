# frozen_string_literal: true

module BwRex
  class ArchiveMatchProfileSession < BwRex::Core::BaseSession
    model MatchProfiles

    attr_accessor :contact_email, :current

    def run
      self.contact_id = Contacts.new(email: contact_email).search_ids_by_email.first
      self.current = instance.find
      to_archive.update if current
    end

    def to_archive
      instance.tap do |ist|
        ist.id = current['_id']
        ist.profile_name = new_profile_name
        ist.campaigns = merge_lists([], current.dig('_related', 'campaigns'), :frequency)
      end
    end

    def new_profile_name
      "Archived '#{current['profile_name']}' [#{Time.current.strftime('%d/%m/%Y')}]"
    end
  end
end
