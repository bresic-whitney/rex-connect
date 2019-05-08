# frozen_string_literal: true

module RSpec
  module DSL
    class Dummy
      include BwRex::Core::Model

      attributes :id, :range # declarative - optional

      action :check do
        field :id
        field :range, range: true
      end
    end

    class DummyAlias
      include BwRex::Core::Model

      as 'RexModel'

      action :check, as: 'rexCheck' do
        field :id
      end
    end
  end
end

RSpec.describe BwRex::Core::DSL do
  describe 'InstanceMethods' do
    subject { RSpec::DSL::Dummy.new }

    describe '.new' do
      it 'initialize with hash' do
        dummy = RSpec::DSL::Dummy.new(id: 100)
        expect(dummy.id).to eq(100)
      end

      it 'ignores not configured fields' do
        dummy = RSpec::DSL::Dummy.new(unknown: 'Value')
        expect(dummy).not_to respond_to(:unknown)
      end
    end

    describe '#attributes' do
      it 'gets configured attribute names' do
        expect(subject.attribute_names).to eq(%i[id range range_min range_max])
      end

      it 'sets only configured attributes' do
        subject.attributes = { id: 100, unknown: 'Value' }
        expect(subject.id).to eq(100)
        expect(subject).not_to respond_to(:unknown)
      end

      it 'gets configured attribute' do
        subject.id = 100
        subject.range = [5, 10]
        expect(subject.attributes).to include(id: 100, range: [5, 10])
      end
    end
  end

  describe 'ClassMethods' do
    subject { RSpec::DSL::Dummy }

    describe '.action' do
      let(:dummy) { subject.new }

      before do
        allow(RSpec::DSL::Dummy).to receive(:new).and_return(dummy)
        allow(dummy).to receive(:request).and_return('result')
      end

      it 'executes the appropriate action' do
        expect(subject.new.check).to eq('result')
      end

      it 'works also as class method' do
        expect(subject.check).to eq('result')
      end
    end

    describe '#query' do
      it 'fails when action does not exist' do
        instance = subject.new(id: 100)
        expect { instance.query(:unknown) }.to raise_error('Action \'unknown\' not configured.')
      end

      it 'returns the query requested' do
        instance = subject.new(id: 100)
        expect(instance.query(:check)).to eq(method: 'Dummy::check', args: { id: 100 })
      end

      it 'works also as class method' do
        expect(subject.query(:check, id: 100)).to eq(method: 'Dummy::check', args: { id: 100 })
      end

      context 'when alias is set' do
        subject { RSpec::DSL::DummyAlias }

        it 'returns the query requested' do
          instance = subject.new(id: 100)
          expect(instance.query(:check)).to eq(method: 'RexModel::rexCheck', args: { id: 100 })
        end

        it 'works also as class method' do
          expect(subject.query(:check, id: 100)).to eq(method: 'RexModel::rexCheck', args: { id: 100 })
        end
      end
    end
  end
end
