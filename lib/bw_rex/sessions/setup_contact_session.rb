# frozen_string_literal: true

module BwRex
  class SetupContactSession < BwRex::Core::BaseSession
    model Contacts

    def run
      id = create if ids.empty?
      id = update unless ids.empty?
      id = combine if ids.size > 1
      id
    end

    private

    def update
      same_name? ? ids.first : instance(id: ids.first).update
    end

    def combine
      winning_id, *losing_ids = ids
      Duplications.combine(winning_id: winning_id, losing_ids: losing_ids)
      winning_id
    end

    def ids
      @ids ||= instance.search_ids_by_email.sort
    end

    def first
      @first ||= instance(id: ids.first).read
    end

    def same_name?
      first.dig('_related', 'contact_names').any? do |e|
        e['name_first'] == first_name && e['name_last'] == last_name
      end
    end
  end
end
