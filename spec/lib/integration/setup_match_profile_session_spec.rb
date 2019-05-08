# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::SetupMatchProfileSession, type: :feature do
  describe '#run' do
    subject { described_class.new(match_profile_data) }

    let(:email) { 'setup_match_profile_integration@test.com' }

    let(:match_profile_data) do
      { tags: ['Family'], frequency: 'daily', suburbs: ['Botany'], property_type: 'House', contact_email: email }
    end

    let(:contact_id) { BwRex::Contacts.create(email: email, first_name: 'Luigi', last_name: 'Pirandello') }

    before do
      BwRex::Contacts.search_ids_by_email(email: email).each do |id|
        BwRex::Contacts.trash(id: id)
      end
    end

    context 'when match profile is not set yet' do
      it 'creates a new contact match profile' do
        contact_id
        subject.notes = 'Some random notes'
        id = subject.run
        match_profile = BwRex::MatchProfiles.read(id: id)
        notes = BwRex::Notes.search(contact_id: match_profile['contact']['id'])
        expect(notes[0]['note']).to eq('Some random notes')
      end
    end

    context 'when match profile is set already' do
      it 'updates the match profile' do
        ex_id = BwRex::MatchProfiles.create(contact_id: contact_id)

        subject.notes = 'Some random notes'
        id = subject.run
        expect(id.to_s).to eq(ex_id.to_s)

        match_profile = BwRex::MatchProfiles.read(id: id)
        notes = BwRex::Notes.search(contact_id: match_profile['contact']['id'])
        expect(notes[0]['note']).to eq('Some random notes')
      end
    end
  end
end
