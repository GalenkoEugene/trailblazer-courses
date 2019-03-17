# frozen_string_literal: true

RSpec.describe UserInvitations::Operation::Create do
  subject(:result) { described_class.call(current_user: current_user, params: params) }

  let(:token) { 'token' }
  let(:admin) { create(:user, :admin) }
  let(:not_admin_user) { create(:user, is_admin: false) }
  let(:user_invitation) { create(:user_invitation) }

  describe 'Success' do
    let(:current_user) { admin }
    let(:params) { { email: user_invitation.email } }

    context 'when user not exist' do
      it 'creates user invitation link' do
        expect(Lib::Service::TokenCreator::UserInvitation).to(
          receive(:call).and_return(token)
        )
        expect(UserMailer).to receive_message_chain(
          :invite_user, :deliver_later
        ).with(user_invitation.id, token).with(no_args).and_return(true)
        expect(result[:model].class).to eq(user_invitation.class)
        expect(result[:success_semantic]).to eq(:created)
        expect(result).to be_success
      end
    end
  end

  describe 'Failure' do
    shared_examples 'token and mailer' do
      it 'doesn`t create token, doesn`t invite_user' do
        expect(Lib::Service::TokenCreator::UserInvitation).not_to receive(:call)
        expect(UserMailer).not_to receive(:invite_user)
      end
    end

    context 'user is admin' do
      let(:current_user) { admin }

      context 'when email is empty' do
        let(:params) { { } }
        let(:errors) { { email: ['Email can’t be blank'] } }

        it 'has validation errors' do
          expect(result['result.contract.default'].errors.messages).to match errors
          expect(result).to be_failure
        end

        it_behaves_like 'token and mailer'
      end

      context "when email doesn't match regex" do
        let(:params) { { email: 'wrong_email' } }
        let(:errors) { { email: ['Wrong email format'] } }

        it 'has validation errors' do
          expect(result['result.contract.default'].errors.messages).to match errors
          expect(result).to be_failure
        end

        it_behaves_like 'token and mailer'
      end

      context 'when user already exists' do
        let(:params) { { email: not_admin_user.email } }
        let(:errors) { { base: ['User with such email already exists'] } }

        it 'has validation errors' do
          expect(result[:errors]).to match errors
          expect(result).to be_failure
        end

        it_behaves_like 'token and mailer'
      end
    end

    context 'user is not an andmin' do
      let(:current_user) { not_admin_user }
      let(:params) { { email: FFaker::Internet.email } }

      it 'fails' do
        expect(result['result.contract.default']).to be_nil
        expect(result).to be_failure
      end

      it_behaves_like 'token and mailer'
    end
  end
end
