# frozen_string_literal: true

RSpec.describe BwRex::Core::DSL::SearchProxy do
  subject { described_class.new('my_action', model: 'my_model') }

  describe '#criteria' do
    it 'registers a field' do
      subject.criteria :my_condition, value: 10
      expect(subject.fields[:criteria]).not_to be_empty
    end
  end

  describe '#query' do
    let(:expectation) do
      {
        method: 'my_model::my_action',
        args: {
          my_field: 'Ciao!',
          criteria: [{ name: 'my_condition', type: '=', value: 10 }]
        }
      }
    end

    let(:expectation_with_different_type) do
      {
        method: 'my_model::my_action',
        args: {
          my_field: 'Ciao!',
          criteria: [{ name: 'my_condition', type: '>', value: 10 }]
        }
      }
    end

    let(:expectation_with_sort) do
      {
        method: 'my_model::my_action',
        args: {
          my_field: 'Ciao!',
          criteria: [{ name: 'my_condition', type: '=', value: 10 }],
          order_by: { my_sort: 'ASC' }
        }
      }
    end

    it 'adds conditions with default type = ' do
      subject.field :my_field, value: 'Ciao!'
      subject.criteria :my_condition, value: 10
      expect(subject.query(nil)).to eq(expectation)
    end

    it 'adds conditions with custom type ' do
      subject.field :my_field, value: 'Ciao!'
      subject.criteria :my_condition, value: 10, type: '>'
      expect(subject.query(nil)).to eq(expectation_with_different_type)
    end

    it 'sets sort type' do
      subject.field :my_field, value: 'Ciao!'
      subject.criteria :my_condition, value: 10
      subject.order_by :my_sort
      expect(subject.query(nil)).to eq(expectation_with_sort)
    end
  end

  describe '#respond' do
    it 'returns the rows' do
      expect(subject.respond('rows' => [1, 2, 3])).to eq([1, 2, 3])
    end

    it 'returns empty array if rows is not present' do
      expect(subject.respond('result' => [1, 2, 3])).to eq([])
    end
  end

  describe 'FindProxy' do
    subject { BwRex::Core::DSL::FindProxy.new('my_action', model: 'my_model') }

    it 'adds limit and offset' do
      expect(subject.fields[:base].map { |f| f[:name] }).to eq(%i[limit offset])
    end

    it 'changes the name to :search' do
      expect(subject.action_name).to eq(:search)
    end

    it 'responds with the first element' do
      expect(subject.respond('rows' => [1])).to eq(1)
    end
  end
end
