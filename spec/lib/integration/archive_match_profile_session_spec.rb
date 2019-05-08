# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::ArchiveMatchProfileSession, type: :feature do
  describe '#run' do
    subject { described_class.new(contact_email: email) }

    let(:email) { 'archive_match_profile_integration@test.com' }

    let(:contact_id) { BwRex::Contacts.new(email: email, first_name: 'Willy', last_name: 'Shakespeare').create }

    before do
      BwRex::Contacts.new(email: email).search_ids_by_email.each do |id|
        BwRex::Contacts.new(id: id).trash
      end
    end

    context 'when match profile is properly set' do
      it 'creates a new contact and returs the id' do
        BwRex::MatchProfiles.new(contact_id: contact_id, frequency: 'daily').create

        id = subject.run

        expect(id).not_to be_nil

        match_profile = BwRex::MatchProfiles.new(id: id).read
        expect(match_profile['category']).to eq('residential_sale')
        expect(match_profile['profile_name']).to eq("Archived 'BW website' [#{Time.current.strftime('%d/%m/%Y')}]")
        expect(match_profile['_related']['campaigns']).to be_empty
      end
    end
  end
end
