# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::SetupMatchProfileSession do
  describe '#run' do
    subject { described_class.new(contact_email: 'test@email.com', notes: 'Some notes') }

    let(:match_profile) { BwRex::MatchProfiles.new }

    before do
      allow(BwRex::Contacts).to receive(:search_ids_by_email)
        .with(email: 'test@email.com').and_return(%w[909 900])
      allow(BwRex::SystemValues).to receive(:listing_subcat)
        .with('residential_sale', 'Unit').and_return('id' => '400')
      allow(BwRex::SystemValues).to receive(:suburb)
        .with('Sydney').and_return('suburb_or_town' => 'Sydney')
      allow(BwRex::Notes).to receive(:create)
        .with(contact_id: '900', text: 'Some notes')

      allow(BwRex::MatchProfiles).to receive(:new).and_return(match_profile)
    end

    context 'when there are no existent match profiles' do
      let(:campaign) do
        { 'campaign_type' => 'email', 'frequency' => 'daily', 'send_time' => '17:00:00', 'send_day' => 'monday' }
      end

      before do
        allow(match_profile).to receive(:find).and_return(nil)
        allow(match_profile).to receive(:create).and_return('300')
      end

      it 'calls the appropriate services end returns the id' do
        expect(subject.run).to eq('300')
      end

      it 'prepares contact id' do
        subject.run
        expect(match_profile.contact_id).to eq('900')
      end

      it 'prepares listing_categories' do
        subject.property_type = 'Unit'
        subject.run
        expect(match_profile.listing_categories).to eq([{ 'value' => '400' }])
      end

      it 'prepares campaigns' do
        subject.frequency = 'daily'
        subject.run
        expect(match_profile.campaigns).to match([campaign])
      end

      it 'prepares suburbs' do
        subject.suburbs = ['Sydney']
        subject.run
        expect(match_profile.suburbs).to match([{ 'suburb_or_town' => 'Sydney' }])
      end

      it 'prepares tags' do
        subject.tags = ['Modern']
        subject.run
        expect(match_profile.tags).to match([{ 'value' => 'Modern' }])
      end
    end

    context 'when there are existent match profiles' do
      let(:existent_attrs) do
        {
          '_id' => '300',
          '_related' => {
            'listing_categories' => [],
            'suburbs' => [],
            'tags_any' => [],
            'campaigns' => []
          }
        }
      end

      before do
        allow(match_profile).to receive(:find).and_return(existent_attrs)
        allow(match_profile).to receive(:update).and_return('300')
      end

      it 'calls the appropriate services end returns the id' do
        expect(subject.run).to eq('300')
      end
    end
  end
end
