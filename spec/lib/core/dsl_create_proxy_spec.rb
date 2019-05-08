# frozen_string_literal: true

RSpec.describe BwRex::Core::DSL::CreateProxy do
  subject { described_class.new('my_action', model: 'my_model') }

  describe '#return_id?' do
    it 'returns false if not set' do
      expect(subject).not_to be_return_id
    end

    it 'returns true if set' do
      subject = described_class.new('my_action', model: 'my_model', return_id: true)
      expect(subject).to be_return_id
    end
  end

  describe '#query' do
    let(:expectation) { { method: 'my_model::my_action', args: { data: { my_field: 'Ciao!' } } } }
    let(:expectation_with_return_id) do
      { method: 'my_model::my_action', args: { data: { my_field: 'Ciao!' }, return_id: true } }
    end

    it 'wraps the args in to data' do
      subject.field :my_field, value: 'Ciao!'
      expect(subject.query(nil)).to eq(expectation)
    end

    it 'adds the option :return_id if set' do
      subject = described_class.new('my_action', model: 'my_model', return_id: true)
      subject.field :my_field, value: 'Ciao!'
      expect(subject.query(nil)).to eq(expectation_with_return_id)
    end
  end
end
