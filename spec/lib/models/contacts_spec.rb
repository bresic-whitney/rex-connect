# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::Contacts do
  describe '#read' do
    subject { described_class.new(id: '999') }

    let(:query) do
      {
        method: 'Contacts::read',
        args: {
          id: '999'
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:read)).to eq(query)
    end
  end

  describe '#search_ids_by_email' do
    subject { described_class.new(email: 'some@email.com') }

    let(:query) do
      {
        method: 'Contacts::search',
        args: {
          result_format: 'ids',
          criteria: [{
            name: 'contact.email_address',
            type: '=',
            value: 'some@email.com'
          }]
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:search_ids_by_email)).to eq(query)
    end
  end

  describe '#create' do
    subject do
      described_class.new(email: 'some@email.com', phone: '555-888', first_name: 'George', last_name: 'harris')
    end

    let(:query) do
      {
        method: 'Contacts::create',
        args: {
          data: {
            type: 'person',
            _related: {
              contact_emails: [{
                email_desc: 'default',
                email_primary: '1',
                email_address: 'some@email.com'
              }],
              contact_names: [{
                name_first: 'George',
                name_last: 'harris'
              }],
              contact_phones: [{
                phone_type: 'default',
                phone_primary: '1',
                phone_number: '555-888'
              }]
            }
          },
          return_id: true
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:create)).to eq(query)
    end
  end

  describe '#update' do
    subject { described_class.new(id: '555', first_name: 'George', last_name: 'harris') }

    let(:query) do
      {
        method: 'Contacts::update',
        args: {
          data: {
            _id: '555',
            _related: {
              contact_names: [{
                name_first: 'George',
                name_last: 'harris'
              }]
            }
          }
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:update)).to eq(query)
    end
  end
end
