# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::Notes do
  describe '#create' do
    subject { described_class.new(contact_id: '999', text: 'Some Text') }

    let(:query) do
      {
        method: 'Notes::create',
        args: {
          data: {
            note_type_id: 'note',
            note: 'Some Text',
            _related: {
              note_contacts: [
                { contact_id: '999' }
              ]
            }
          }
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:create)).to eq(query)
    end
  end
end
