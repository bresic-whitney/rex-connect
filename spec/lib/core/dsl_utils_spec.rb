# frozen_string_literal: true

require 'ostruct'

RSpec.describe BwRex::Core::DSL::Utils do
  subject do
    klass = Class.new.send(:include, described_class)
    klass.new
  end

  describe '.pack' do
    it 'creates an hash' do
      expectation = { name: :my_field, value: :my_field, options: {} }
      expect(subject.pack(:my_field)).to eq(expectation)
    end

    it 'uses alias for name' do
      expectation = { name: :my_alias, value: :my_field, options: { as: :my_alias } }
      expect(subject.pack(:my_field, as: :my_alias)).to eq(expectation)
    end
  end

  describe '.unpack' do
    let(:instance) do
      OpenStruct.new(name: 'Jimmy Cool', age_range: [30, 40], other_range_min: 10, other_range_max: 20, address: nil)
    end

    it 'validates mandatory fields' do
      field = subject.pack(:address, presence: true)
      expect { subject.unpack(field, instance) }.to raise_error('\'address\' cannot be nil on \'Anonymous\'')
    end

    it 'generates static values' do
      field = subject.pack(:my_field, value: 'Some value')

      subject.unpack(field, instance) do |name, value, options|
        expect(name).to eq(:my_field)
        expect(value).to eq('Some value')
        expect(options).to eq(value: 'Some value')
      end
    end

    it 'generates dynamic values' do
      field = subject.pack(:name)

      subject.unpack(field, instance) do |name, value, options|
        expect(name).to eq(:name)
        expect(value).to eq('Jimmy Cool')
        expect(options).to be_empty
      end
    end

    it 'generates dynamic range values' do
      field = subject.pack(:age_range, range: true)

      subject.unpack(field, instance) do |name, value, options|
        expect(name).to eq(:age_range)
        expect(value).to eq(min: 30, max: 40)
        expect(options).to eq(range: true)
      end
    end

    it 'generates dynamic range from split fields' do
      field = subject.pack(:other_range, range: true)

      subject.unpack(field, instance) do |name, value, options|
        expect(name).to eq(:other_range)
        expect(value).to eq(min: 10, max: 20)
        expect(options).to eq(range: true)
      end
    end

    it 'generates default values' do
      field = subject.pack(:address, default: 'Some Street')

      subject.unpack(field, instance) do |name, value, options|
        expect(name).to eq(:address)
        expect(value).to eq('Some Street')
        expect(options).to eq(default: 'Some Street')
      end
    end
  end

  describe '.merge_lists' do
    it 'handles empty lists' do
      expect(subject.merge_lists([], [])).to be_empty
    end

    it 'handles nil lists' do
      expect(subject.merge_lists(nil, nil)).to be_empty
    end

    it 'moves new items' do
      user = [{ 'key' => '1' }]
      server = []
      expect(subject.merge_lists(user, server, :key)).to eq([{ 'key' => '1' }])
    end

    it 'removes deleted items' do
      user = []
      server = [{ '_id' => 100, 'key' => '1' }]
      expect(subject.merge_lists(user, server, :key)).to eq([{ '_id' => 100, '_destroy' => true }])
    end

    it 'ignores same items' do
      user = [{ 'key' => '1' }]
      server = [{ '_id' => 100, 'key' => '1' }]
      expect(subject.merge_lists(user, server, :key)).to be_empty
    end

    it 'adds and remove items' do
      user = [{ 'key' => '2' }]
      server = [{ '_id' => 100, 'key' => '1' }]
      expect(subject.merge_lists(user, server, :key)).to eq([{ 'key' => '2' }, { '_id' => 100, '_destroy' => true }])
    end
  end
end
