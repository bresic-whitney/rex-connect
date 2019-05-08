# frozen_string_literal: true

module BwRex
  class Notes
    include BwRex::Core::Model

    attributes :contact_id

    action :create do
      field :type, as: :note_type_id, default: 'note'
      field :text, as: :note, presence: true
      related do
        field :note_contacts, default: []
      end
    end

    action :search do
      criteria :contact_id, presence: true
    end

    def note_contacts
      [{ contact_id: contact_id }]
    end
  end
end
