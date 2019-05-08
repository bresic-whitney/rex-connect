# frozen_string_literal: true

module BwRex
  class Contacts
    include BwRex::Core::Model

    attributes :first_name, :last_name, :phone

    action :read do
      field :id, presence: true
    end

    action :search_ids_by_email, as: :search do
      field :result_format, value: 'ids'
      criteria :email, as: 'contact.email_address', presence: true
    end

    action :create, return_id: true do
      field :type, value: 'person'
      related do
        field :contact_emails, presence: true
        field :contact_names, presence: true
        field :contact_phones, default: []
      end
    end

    action :update, return_id: true do
      related do
        field :contact_names, default: []
      end
    end

    action :trash

    def contact_emails
      [{ email_desc: 'default', email_primary: '1', email_address: email }]
    end

    def contact_names
      [{ name_first: first_name, name_last: last_name }]
    end

    def contact_phones
      [{ phone_type: 'default', phone_primary: '1', phone_number: phone }] if phone
    end
  end
end
