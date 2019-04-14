# frozen_string_literal: true

RSpec.describe Users::Operation::Create do
  subject(:result) { described_class.call(params: params) }

  let(:user_invitation) { create(:user_invitation) }
  let(:token) { Service::JWTAdapter.encode(aud: 'user_invitation', sub: user_invitation.id, exp: 1.day.from_now.to_i) }
  let(:first_name) { FFaker::Name.first_name }
  let(:last_name) { FFaker::Name.last_name }
  let(:password) { 'Password1!' }
  let(:password_confirmation) { password }
  let(:params) do
    {
      token: token,
      first_name: first_name,
      last_name: last_name,
      password: password,
      password_confirmation: password_confirmation
    }
  end

  describe 'Success' do
    context 'when token valid' do
      it 'creates user' do
        expect(Service::JWTAdapter).to receive(:decode).with(
          token,
          aud: 'user_invitation',
          verify_aud: true
        ).and_call_original
        expect(result[:model].email).to eq(user_invitation.email)
        expect(result[:model].class).to eq(User)
        expect(result).to be_success
      end
    end
  end

  describe 'Failure' do
    shared_examples 'validation errors' do
      it 'has validation errors' do
        expect(result['result.contract.default'].errors.messages).to match errors
        expect(result).to be_failure
      end
    end

    context 'when first_name is blank' do
      it_behaves_like 'validation errors' do
        let(:first_name) { }
        let(:errors) { { first_name: ['First Name can’t be blank'] } }
      end
    end

    context 'when last_name is blank' do
      it_behaves_like 'validation errors' do
        let(:last_name) { }
        let(:errors) { { last_name: ['Last Name can’t be blank'] } }
      end
    end

    context 'when password is blank' do
      it_behaves_like 'validation errors' do
        let(:password) { '' }
        let(:errors) do
          {
            password: [
              'Password can’t be blank',
              'Use a minimum password length of 6 or more characters'
            ]
          }
        end
      end
    end

    context 'when password is too short' do
      it_behaves_like 'validation errors' do
        let(:password) { 'pass' }
        let(:errors) do
          {
            password: [
              'is in invalid format',
              'Use a minimum password length of 6 or more characters'
            ]
          }
        end
      end
    end

    context 'when password does not match' do
      it_behaves_like 'validation errors' do
        let(:password_confirmation) { '!1drowssaP' }
        let(:errors) { { password_confirmation: ['Password and password confirmation do not match'] } }
      end
    end

    context 'when email not unique' do
      before { create(:user, email: user_invitation.email) }

      it_behaves_like 'validation errors' do
        let(:errors) { { email: ['Email must be unique'] } }
      end
    end
  end
end
