# frozen_string_literal: true

RSpec.describe BwRex::Core::Client do
  subject { described_class.new }

  def mock_authenticator
    autenticator = double
    allow(BwRex::Core::Authentication).to receive(:new)
      .with(email: BwRex.configuration.email,
            password: BwRex.configuration.password,
            environment_id: BwRex.configuration.environment_id)
      .and_return(autenticator)
    allow(autenticator).to receive(:query).with(:login).and_return('login_query')
    allow(autenticator).to receive(:login).and_return('valid-token')
  end

  describe '#post' do
    let(:request) { { method: 'test' } }

    let(:response) { { result: 'positive', error: nil } }

    let(:alt_response) { { result: 'positive', error: nil } }

    before do
      BwRex.token = 'valid-token'
      regular_resp = { status: 200, body: JSON.generate(response) }
      alternative_resp = { status: 200, body: JSON.generate(alt_response) }
      stub_request(:post, BwRex.configuration.endpoint)
        .with(body: JSON.generate(request.merge(token: 'valid-token')))
        .to_return(regular_resp, alternative_resp)
    end

    after do
      BwRex.token = nil
    end

    context 'when token is already valid' do
      it 'returns the appropriate result' do
        expect(subject.post(request)).to eq('positive')
      end
    end

    context 'when token is nil' do
      before do
        BwRex.token = nil
        mock_authenticator
      end

      it 'returns the appropriate value' do
        expect(subject.post(request)).to eq('positive')
      end

      it 'assigns the token to the global variable' do
        subject.post(request)
        expect(BwRex.token).to eq('valid-token')
      end
    end

    context 'when response is a generic error' do
      let(:response) do
        { result: nil, error: { message: 'Some message', type: 'GenericException' } }
      end

      it 'raises an error' do
        expect { subject.post(request) }.to raise_error(BwRex::Core::ServerError)
      end
    end

    context 'when response is a token error' do
      let(:response) do
        { result: nil, error: { message: 'Some message', type: 'TokenException' } }
      end

      it 'raises an error' do
        mock_authenticator

        expect(subject.post(request)).to eq('positive')
      end
    end
  end

  describe '#new_token' do
    before do
      mock_authenticator
    end

    it 'returns nil when recursive' do
      expect(subject.new_token('login_query')).to be_nil
    end

    it 'returns a new token' do
      expect(subject.new_token('not_a_login_query')).to eq('valid-token')
    end

    context 'when multi-user configuration is set' do

      around(:each) do |each|
        old = BwRex.configuration.multi_user
        BwRex.configuration.multi_user = true
        each.run
        BwRex.configuration.multi_user = old
      end

      it 'returns nil' do
        expect(subject.new_token('not_a_login_query')).to be_nil
      end
    end
  end
end
