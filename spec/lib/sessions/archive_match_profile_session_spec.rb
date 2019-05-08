# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::ArchiveMatchProfileSession do
  describe '#run' do
    subject do
      described_class.new.tap { |me| me.contact_email = 'test@email.com' }
    end

    let(:now) { Time.current }

    let(:contact) { BwRex::Contacts.new }

    let(:match_profile) { BwRex::MatchProfiles.new }

    let(:match_profile_data) do
      { '_id' => '20',
        'profile_name' => 'BW Website',
        '_related' => { 'campaigns' => [{ '_id' => '100', 'frequency' => 'daily' }] } }
    end

    before do
      allow(Time).to receive(:now).and_return(now)
      allow(BwRex::Contacts).to receive(:new).with(email: 'test@email.com').and_return(contact)
      allow(contact).to receive(:search_ids_by_email).and_return([999])
    end

    context 'when match profile exists' do
      before do
        allow(BwRex::MatchProfiles).to receive(:new).and_return(match_profile)
        allow(match_profile).to receive(:find).and_return(match_profile_data)
        allow(match_profile).to receive(:update).and_return('20')
      end

      it 'calls the appropriate services end returns the id' do
        expect(subject.run).to be('20')
      end

      it 'updates the profile name' do
        subject.run
        to_archive = subject.to_archive

        expect(to_archive.id).to eq('20')
        expect(to_archive.campaigns).to match([{ '_id' => '100', '_destroy' => true }])
        expect(to_archive.profile_name).to eq("Archived 'BW Website' [#{now.strftime('%d/%m/%Y')}]")
      end
    end

    context 'when match profile does not exists' do
      before do
        allow(BwRex::MatchProfiles).to receive(:new).and_return(match_profile)
        allow(match_profile).to receive(:find).and_return(nil)
      end

      it 'returns nil' do
        expect(subject.run).to be_nil
      end
    end
  end
end
