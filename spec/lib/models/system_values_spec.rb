# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BwRex::SystemValues do
  describe '#list' do
    subject { described_class.new(list_name: 'some_category') }

    let(:query) do
      {
        method: 'SystemValues::getCategoryValues',
        args: {
          list_name: 'some_category'
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:list)).to eq(query)
    end
  end

  describe '#suburbs' do
    subject { described_class.new(search_string: 'Botany') }

    let(:query) do
      {
        method: 'SystemValues::autocompleteCategoryValues',
        args: {
          list_name: 'suburbs',
          search_string: 'Botany'
        }
      }
    end

    it 'produces the appropriate query' do
      expect(subject.query(:suburbs)).to eq(query)
    end
  end
end
