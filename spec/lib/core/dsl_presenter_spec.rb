# frozen_string_literal: true

# TODO: Add specs for id
# TODO: Add specs for options :match, :proc

module RSpec
  module DSL
    module Presenter
      class DummyProxy
        include BwRex::Core::Model

        map do
          field :name, as: 'full_name'
          field :email, as: 'contacts.email'
        end
      end
    end
  end
end

RSpec.describe BwRex::Core::DSL::Presenter do
  subject { described_class.new(host) }

  let(:host) { class_double('Dummy') }

  describe '.new' do
    it 'records the host' do
      expect(subject.host).to eq(host)
    end

    it 'initializes attributes' do
      expect(subject.attributes).to be_empty
    end

    it 'initializes fields' do
      expect(subject.fields).to be_empty
    end

    it 'initializes options' do
      expect(subject.options).to be_empty
    end
  end

  describe '#field' do
    before do
      subject.field(:my_field, as: 'remote.field')
    end

    it 'registers a field' do
      expect(subject.fields).not_to be_empty
    end

    it 'registers an attribute' do
      expect(subject.attributes).not_to be_empty
    end

    context 'with a proxy presenter' do
      it 'fails with error if proxy is not of the appropriate type' do
        message = "The partial presenter 'String' for the field 'my_field' must include 'BwRex::Core::Model'"
        expect { subject.field(:my_field, use: String) }.to raise_error(message)
      end
    end
  end

  describe '#render' do
    context 'when no fields are configured' do
      it 'returns the same output' do
        expect(subject.render('some-object')).to eq('some-object')
      end
    end

    context 'when input is not an Hash' do
      it 'returns the same output' do
        subject.field(:name, as: 'full_name')
        expect(subject.render('some-object')).to eq('some-object')
      end
    end

    context 'with plain object' do
      let(:instance) { spy }

      let(:proxy_class) { object_spy('RSpec::DSL::Presenter::DummyProxy') }

      let(:complex_result) do
        {
          'people' => [
            { '_id' => '1', 'full_name' => 'Jason', 'contacts' => { 'email' => 'test_1@example.com' } },
            { '_id' => '2', 'full_name' => 'Mike', 'contacts' => { 'email' => 'test_2@example.com' } }
          ]
        }
      end

      before do
        allow(host).to receive(:new).and_return(instance)
      end

      context 'with id' do
        before do
          subject.field(:name)
          allow(instance).to receive(:name=).with('Danny')
        end

        it 'renders the id field as public' do
          response = { 'id' => '1', 'name' => 'Danny' }

          expect(subject.render(response)).to eq(instance)
          expect(instance).to have_received(:id=).with('1')
        end

        it 'renders the id field as private' do
          response = { '_id' => '1', 'name' => 'Danny' }

          expect(subject.render(response)).to eq(instance)
          expect(instance).to have_received(:id=).with('1')
        end
      end

      it 'renders a simple attribute without alias' do
        response = { 'name' => 'Danny' }
        subject.field(:name)

        expect(subject.render(response)).to eq(instance)
        expect(instance).to have_received(:name=).with('Danny')
      end

      it 'renders a simple attribute using an alias' do
        response = { 'full_name' => 'Danny' }
        subject.field(:name, as: 'full_name')

        expect(subject.render(response)).to eq(instance)
        expect(instance).to have_received(:name=).with('Danny')
      end

      it 'ignores other attributes' do
        response = { 'full_name' => 'Danny' , 'age' => 40 }
        subject.field(:name, as: 'full_name')

        expect(subject.render(response)).to eq(instance)
        expect(instance).to have_received(:name=).with('Danny')
        expect(instance).not_to have_received(:age=)
      end

      it 'ignores non existent attributes' do
        response = { 'first_name' => 'Danny' }
        subject.field(:name, as: 'full_name')

        expect(subject.render(response)).to eq(instance)
        expect(instance).not_to have_received(:name=)
      end

      it 'ignores attributes with null value' do
        response = { 'full_name' => nil }
        subject.field(:name, as: 'full_name')

        expect(subject.render(response)).to eq(instance)
        expect(instance).not_to have_received(:name=)
      end

      it 'renders a nested attribute' do
        response = { 'contacts' => { 'primary_email' => 'test@example.com' } }
        subject.field(:email, as: 'contacts.primary_email')

        expect(subject.render(response)).to eq(instance)
        expect(instance).to have_received(:email=).with('test@example.com')
      end

      it 'renders an attribute as array of attributes' do
        response = {
          'contacts' => [
            { 'id' => '1', 'email' => 'test_1@example.com' },
            { 'id' => '2', 'email' => 'test_2@example.com' }
          ]
        }
        subject.field(:emails, as: 'contacts.email')

        expect(subject.render(response)).to eq(instance)
        expect(instance).to have_received(:emails=).with(['test_1@example.com', 'test_2@example.com'])
      end

      it 'renders an attribute as array of objects' do
        response = {
          'contacts' => [
            { 'id' => '1' },
            { 'id' => '2' }
          ]
        }
        subject.field(:users, as: 'contacts')

        expect(subject.render(response)).to eq(instance)
        expect(instance).to have_received(:users=).with([{ 'id' => '1' }, { 'id' => '2' }])
      end

      it 'renders an attribute using a proxy' do
        subject.field(:users, as: 'people', use: proxy_class)
        allow(proxy_class).to receive(:render).with(complex_result['people']).and_return([1, 2])

        expect(subject.render(complex_result)).to eq(instance)
        expect(instance).to have_received(:users=).with([1, 2])
      end

      context 'with multiple fields with same name' do
        it 'registers all the fields but only 1 attribute' do
          subject.field(:name, as: 'full_name')
          subject.field(:name, as: 'real_name')
          subject.field(:name)

          expect(subject.fields.size).to eq(3)
          expect(subject.attributes.size).to eq(1)
        end
        [
          { 'full_name' => 'Danny' },
          { 'full_name' => nil },
        ]

      end
    end
  end
end
