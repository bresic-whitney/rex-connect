# frozen_string_literal: true

RSpec.describe BwRex do
  it 'allows token memoization' do
    described_class.token = 'some-token'
    expect(described_class.token).to be 'some-token'
  end

  it 'has a version number' do
    expect(described_class.version).not_to be nil
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
    multi_user: false
  }.keys.each do |key|
    it { described_class.configuration.respond_to? key }
  end
end
