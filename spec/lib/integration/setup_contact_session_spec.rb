# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::SetupContactSession, type: :feature do
  describe '#run' do
    subject { described_class.new(contact_data) }

    let(:email) { 'setup_contact_integration@test.com' }

    let(:contact_data) do
      { first_name: 'Mark', last_name: 'Twain', email: email }
    end

    before do
      BwRex::Contacts.new(email: email).search_ids_by_email.each do |id|
        BwRex::Contacts.new(id: id).trash
      end
    end

    context 'when contact does not extist' do
      it 'creates a new contact and returs the id' do
        expect(subject.search_ids_by_email).to be_empty

        subject.run

        expect(subject.search_ids_by_email.length).to be(1)
      end
    end

    context 'when contact already extists' do
      it 'update the contact and returs the id' do
        BwRex::Contacts.new(first_name: 'Sonia', last_name: 'Twain', email: email).create

        expect(subject.search_ids_by_email.length).to be(1)

        id = subject.run

        expect(subject.search_ids_by_email.length).to be(1)

        contact = BwRex::Contacts.new(id: id).read
        names = contact.dig('_related', 'contact_names')
        expect(names.length).to be(2)
      end
    end

    context 'when contacts already extist' do
      it 'update the contact, clone the other contacts and returs the id' do
        BwRex::Contacts.create(first_name: 'Mila', last_name: 'Twain', email: email)
        BwRex::Contacts.create(first_name: 'Sonia', last_name: 'Twain', email: email)

        expect(subject.search_ids_by_email.length).to be(2)

        id = subject.run

        expect(subject.search_ids_by_email.length).to be(1)

        contact = BwRex::Contacts.read(id: id)
        names = contact.dig('_related', 'contact_names')
        expect(names.length).to be(3)
      end
    end
  end
end
