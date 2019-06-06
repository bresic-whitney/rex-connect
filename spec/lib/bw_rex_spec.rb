# frozen_string_literal: true

RSpec.describe BwRex do
  module BwRex
    class SomeModel
      include BwRex::Core::Model

      map do
        field :ext_key, as: 'ext_alias'
      end
    end
  end

  it 'allows token memoization' do
    described_class.token = 'some-token'
    expect(described_class.token).to be 'some-token'
  end

  it 'has a version number' do
    expect(described_class.version).not_to be nil
  end

  describe '.initialize' do
    let(:model) { BwRex::SomeModel }

    let(:presenters) { model.instance_variable_get('@presenters') }

    let(:profiles) do
      {
        some_model: {
          default: {
            key: 'alias',
            ext_key: 'conf_alias'
          },
          alternative: {
            alt_key: 'alt_alias'
          }
        }
      }
    end

    before do
      described_class.configuration.profiles = profiles
      allow(ObjectSpace).to receive(:each_object).with(Class).and_return([model])
      described_class.initialize(['BwRex'])
    end

    after do
      described_class.configuration.profiles = nil
    end

    it { expect(presenters.size).to be(2) }
    it { expect(presenters[:default].fields.size).to be(2) }
    it { expect(presenters[:alternative].fields.size).to be(1) }
  end

  describe '.welcome' do
    it 'prints a welcome message' do
      allow(BwRex::HealthCheck).to receive(:verify).and_return(true)

      expect(described_class.welcome).to eq("Rex Server at '#{described_class.configuration.endpoint}' is ON")
    end
  end

  {
    logger: 'some-logger',
    endpoint: 'some-endpoint',
    email: 'some-email',
    password: 'some-password',
    multi_user: false,
    profiles: { key: 'value' }
  }.keys.each do |key|
    it { described_class.configuration.respond_to? key }
  end
end
