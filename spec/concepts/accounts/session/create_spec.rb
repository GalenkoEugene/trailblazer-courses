# frozen_string_literal: true

RSpec.describe Accounts::Session::Operation::Create do
  subject(:result) { described_class.call(params: params) }

  let(:params) { {} }
  let(:secure_password) { 'securePassword!' }
  let(:user) { create(:user, password: secure_password) }
  let(:token) { double(:auth_token) }
  let(:cache_key) { auth_token_key_for(user) }

  before do
    allow(Auth::Token::Session).to receive(:generate).with(user).and_return(token)
    result
  end

  describe 'Success' do
    let(:params) { { email: user.email, password: secure_password } }

    it 'create session token' do
      expect(result[:auth]).to eq(token)
      expect(result).to be_success
    end

    it 'add user token to whitelist' do
      expect(Rails.cache.read(cache_key)).to eq(token.to_s)
    end
  end

  describe 'Failure' do
    shared_examples 'session creation failure' do
      it 'does not create session token' do
        expect(result[:auth]).to be_nil
        expect(result).to be_failure
      end
    end

    context 'with wrong password' do
      let(:params) { { email: user.email, password: 'invalid password' } }
      let(:errors) { { base: ['Email or password is incorrect'] } }

      it_behaves_like 'session creation failure'

      it 'has validation errors' do
        expect(result[:errors]).to match errors
      end
    end

    context 'wiht blank password' do
      let(:params) { { email: user.email, password: '' } }
      let(:errors) { { password: ['Password can’t be blank'] } }

      it_behaves_like 'session creation failure'

      it 'has validation errors' do
        expect(result['result.contract.default'].errors.messages).to match errors
      end
    end

    context 'with wrong email' do
      let(:params) { { email: 'invalid@email.net', password: secure_password } }
      let(:errors) { { base: ['Email or password is incorrect'] } }

      it_behaves_like 'session creation failure'

      it 'has validation errors' do
        expect(result[:errors]).to match errors
      end
    end

    context 'wiht blank email' do
      let(:params) { { email: '', password: secure_password } }
      let(:errors) { { email: ['Email can’t be blank'] } }

      it_behaves_like 'session creation failure'

      it 'has validation errors' do
        expect(result['result.contract.default'].errors.messages).to match errors
      end
    end
  end
end
