# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::CustomFields do
  describe '#list' do
    subject { described_class.new(service_name: 'Listing') }

    let(:query) do
      {
        method: 'CustomFields::describeSearchFields',
        args: {
          service_name: 'Listing'
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:list)).to eq(query)
    end
  end

  describe '#set' do
    subject { described_class.new(service_name: 'Listing', id: 999, value_map: [{ 'code' => 'value' }]) }

    let(:query) do
      {
        method: 'CustomFields::setFieldValues',
        args: {
          service_name: 'Listing',
          service_object_id: 999,
          value_map: [{ 'code' => 'value' }]
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:set)).to eq(query)
    end
  end

  describe '#get' do
    subject { described_class.new(service_name: 'Listing', id: 999) }

    let(:query) do
      {
        method: 'CustomFields::getValuesKeyedByFieldId',
        args: {
          service_name: 'Listing',
          service_object_id: 999
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:get)).to eq(query)
    end
  end
end
