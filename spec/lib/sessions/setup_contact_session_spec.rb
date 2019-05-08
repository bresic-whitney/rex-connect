# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::SetupContactSession do
  describe '#run' do
    subject { described_class.new(contact_attrs) }

    let(:contact_attrs) do
      { id: '20', email: 'mt@email.com', first_name: 'Michael', last_name: 'Type', phone: '555-444-000' }
    end

    let(:contact) { BwRex::Contacts.new }

    before do
      allow(BwRex::Contacts).to receive(:new).with(contact_attrs).and_return(contact)
    end

    context 'when there are no contacts with the same email' do
      before do
        allow(contact).to receive(:search_ids_by_email).and_return([])
        allow(contact).to receive(:create).and_return('20')
      end

      it 'calls the appropriate services end returns the id' do
        expect(subject.run).to be('20')
      end
    end

    context 'when there is one contact with the same email and different name' do
      let(:existent_attrs) do
        {
          '_id' => '20',
          '_related' => {
            'contact_names' => [{ 'name_first' => 'George', 'name_last' => 'Simmons' }]
          }
        }
      end

      before do
        allow(contact).to receive(:search_ids_by_email).and_return(['20'])
        allow(contact).to receive(:read).and_return(existent_attrs)
        allow(contact).to receive(:update).and_return('20')
      end

      it 'calls the appropriate services end returns the id' do
        expect(subject.run).to be('20')
      end
    end

    context 'when there is one contact with the same email and same name' do
      let(:existent_attrs) do
        {
          '_id' => '20',
          '_related' => {
            'contact_names' => [{ 'name_first' => 'Michael', 'name_last' => 'Type' }]
          }
        }
      end

      before do
        allow(contact).to receive(:search_ids_by_email).and_return(['20'])
        allow(contact).to receive(:read).and_return(existent_attrs)
      end

      it 'calls the appropriate services end returns the id' do
        expect(subject.run).to be('20')
      end
    end

    context 'when there are more contact with the same email' do
      let(:existent_attrs) do
        {
          '_id' => '20',
          '_related' => {
            'contact_names' => [{ 'name_first' => 'Michael', 'name_last' => 'Type' }]
          }
        }
      end

      before do
        allow(contact).to receive(:search_ids_by_email).and_return(%w[40 20 60])
        allow(contact).to receive(:read).and_return(existent_attrs)
        allow(BwRex::Duplications).to receive(:combine).with(winning_id: '20', losing_ids: %w[40 60])
      end

      it 'calls the appropriate services end returns the id' do
        expect(subject.run).to be('20')
      end
    end
  end
end
