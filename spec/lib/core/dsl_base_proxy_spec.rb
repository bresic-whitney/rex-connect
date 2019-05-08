# frozen_string_literal: true

RSpec.describe BwRex::Core::DSL::BaseProxy do
  subject { described_class.new('my_action', model: 'my_model') }

  describe '.new' do
    it 'records the model name from the options' do
      expect(subject.model_name).to eq('my_model')
    end

    it 'uses an alias for the name' do
      expect(described_class.new('my_action', as: 'my_alias', model: 'my_model').action_name).to eq('my_alias')
    end

    context 'when model name is missing' do
      it 'raises an error' do
        expect { described_class.new('my_action') }.to raise_error('Model name required for action \'my_action\'')
      end
    end
  end

  describe '#method_name' do
    it 'mounts model name and action name' do
      expect(subject.method_name).to eq('my_model::my_action')
    end
  end

  describe '#query' do
    let(:simple_expectation) { { method: 'my_model::my_action', args: { my_field: 'Ciao!' } } }
    let(:complex_expectation) do
      {
        method: 'my_model::my_action',
        args: {
          my_field: 'Ciao!',
          _related: { my_rel_field: true },
          extra_options: { my_extra_field: true }
        }
      }
    end

    it 'returns the query with basic fields' do
      subject.field :my_field, value: 'Ciao!'
      expect(subject.query(nil)).to eq(simple_expectation)
    end

    it 'returns the query including related and extra_options fields' do
      subject.field :my_field, value: 'Ciao!'
      subject.related { field(:my_rel_field, value: true) }
      subject.extra_options { field(:my_extra_field, value: true) }

      expect(subject.query(nil)).to eq(complex_expectation)
    end
  end

  describe '#respond' do
    it 'returns the same value' do
      expect(subject.respond('out')).to eq('out')
    end
  end

  describe '#field' do
    it 'registers a field' do
      subject.field(:my_field)
      expect(subject.fields[:base]).not_to be_empty
    end
  end

  describe '#related' do
    it 'registers a field' do
      subject.related { field(:my_field) }

      expect(subject.fields[:_related]).not_to be_empty
    end
  end

  describe '#extra_options' do
    it 'registers an extra field' do
      subject.extra_options { field(:my_field) }

      expect(subject.fields[:extra_options]).not_to be_empty
    end
  end

  describe '#register' do
    it 'creates a field object' do
      subject.field(:my_field)

      expect(subject.fields[:base].first).to eq(name: :my_field, value: :my_field, options: {})
    end

    it 'uses alias name if configured' do
      subject.field(:my_field, as: :alias_field)

      expect(subject.fields[:base].first).to eq(name: :alias_field, value: :my_field, options: { as: :alias_field })
    end

    it 'adds the name to the attribute list' do
      subject.field(:my_field, as: :alias_field)

      expect(subject.attributes).to eq([:my_field])
    end

    it 'does not add the name to the attribute list if value option is set' do
      subject.field(:my_field, value: 'Static value')

      expect(subject.attributes).to be_empty
    end

    it 'adds the range util fields if range option is set' do
      subject.field(:my_field, range: true)

      expect(subject.attributes).to eq(%i[my_field my_field_min my_field_max])
    end
  end
end
