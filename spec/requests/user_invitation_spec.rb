# frozen_string_literal: true

RSpec.describe 'UserInvitation', type: :request do
  include ApiDoc::UserInvitation::Api

  describe 'POST #create' do
    include ApiDoc::UserInvitation::Create

    let(:admin) { create(:user, :admin) }
    let(:user) { create(:user, is_admin: false) }
    let(:email) { FFaker::Internet.email }
    let(:headers) { authorization_header_for(current_user) }
    let(:params) { { email: email } }

    before { post '/user_invitation', params: params, headers: headers }

    describe 'Success' do
      let(:current_user) { admin }

      context 'when email not registered' do
        it 'creates user_invitation_token', :dox do
          expect(response).to be_created
          expect(response.body).to be_empty
        end
      end
    end

    describe 'Fail' do
      context "when email doesn't match regex" do
        let(:current_user) { admin }
        let(:params) { { email: 'wrong_email' } }

        it 'renders errors', :dox do
          expect(response).to be_unprocessable
          expect(response).to match_json_schema('errors')
        end
      end

      context 'when email registered' do
        let(:current_user) { admin }
        let(:params) { { email: user.email } }

        it 'renders errors', :dox do
          expect(response).to be_unprocessable
          expect(response).to match_json_schema('errors')
        end
      end

      context 'when authorization headers is not valid' do
        let(:headers) { {} }

        it 'renders errors' do
          expect(response).to be_unauthorized
          expect(response).to match_json_schema('errors')
        end
      end
    end
  end
end
