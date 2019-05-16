# frozen_string_literal: true

module RSpec
  module Model
    class Dummy
      include BwRex::Core::Model

      as 'RexModel'

      attributes :id, :range # declarative - optional

      action :failure

      action :success do
        field :id, presence: true
        field :range, range: true
      end
    end
  end
end

RSpec.describe BwRex::Core::Model do
  subject { RSpec::Model::Dummy.new }

  describe '#request' do
    let(:request) { { method: 'RexModel::success', args: { id: 100 } } }

    let(:response) { { result: 'positive', error: nil } }

    let(:token) { 'valid-token' }

    before do
      BwRex.token = token
      stub_request(:post, BwRex.configuration.endpoint)
        .with(body: JSON.generate(request.merge(token: 'valid-token')))
        .to_return(status: 200, body: JSON.generate(response))
    end

    context 'with success' do
      it 'accepts the raw query end return the raw response' do
        expect(subject.request(request)).to eq('positive')
      end

      it 'returns the proper output' do
        subject.id = 100
        expect(subject.success).to eq('positive')
      end

      it 'fails with error where fields is required' do
        expect { subject.success }.to raise_error("'id' cannot be nil on 'RexModel::success'")
      end
    end

    context 'with failure' do
      let(:request) { { method: 'RexModel::failure', args: {} } }

      let(:response) { { result: nil, error: { type: 'GenericException' } } }

      it 'fails with error where request fails' do
        expect { subject.failure }.to raise_error(BwRex::Core::ServerError)
      end
    end

    context 'with token set locally via constructor' do
      subject { RSpec::Model::Dummy.new(token: 'valid-token') }

      let(:token) { nil }

      it 'accepts the raw query end return the raw response' do
        expect(subject.request(request)).to eq('positive')
      end
    end

    context 'with token set locally via accessor' do
      let(:token) { nil }

      it 'accepts the raw query end return the raw response' do
        subject.token = 'valid-token'
        expect(subject.request(request)).to eq('positive')
      end
    end
  end

  describe '#log' do
    let(:logger) { spy }

    before do
      allow(BwRex.configuration).to receive('logger').and_return(logger)
    end

    context 'when logger level is higher' do
      before do
        allow(logger).to receive('debug?').and_return(false)
      end

      it 'does not log the message' do
        subject.log(:debug, 'Some message')
        expect(logger).not_to have_received('debug')
      end
    end

    context 'when logger level is included' do
      before do
        allow(logger).to receive('debug?').and_return(true)
      end

      it 'logs basic info' do
        subject.log(:debug, 'Some message')

        expectation = { component: 'Rex', class_name: 'RSpec::Model::Dummy', msg: 'Some message' }
        expect(logger).to have_received('debug').with(expectation)
      end

      it 'merges other parameters' do
        subject.log(:debug, 'Msg', foo: 'test')

        expectation = { component: 'Rex', class_name: 'RSpec::Model::Dummy', msg: 'Msg', foo: 'test' }
        expect(logger).to have_received('debug').with(expectation)
      end

      context 'when query is Authentication::login' do
        let(:expectation) do
          {
            component: 'Rex',
            class_name: 'RSpec::Model::Dummy',
            msg: 'Login',
            request: {
              method: 'Authentication::login',
              args: {}
            }
          }
        end

        it 'removes sensitive arguments' do
          request = { method: 'Authentication::login', args: { email: 'very-secret', password: 'more-secret' } }
          subject.log(:debug, 'Login', request: request)

          expect(logger).to have_received('debug').with(expectation)
        end
      end
    end
  end
end
