# frozen_string_literal: true

RSpec.describe 'Seessions', :dox, type: :request do
  describe 'GET #create' do
    include ApiDoc::Sessions::Destroy

    let(:password) { 'SecurePassword1!' }
    let(:email) { 'email@example.com' }
    let!(:user) { create(:user, email: email, password: password) }

    before do
      post '/account/session', params: params
    end

    describe 'Success' do
      let(:params) { { email: email, password: password } }

      it 'match json schema' do
        expect(response.body).to match_json_schema('account/session/create')
      end

      it 'create session' do
        expect(response).to be_created
      end
    end

    describe 'Failure' do
      context 'when wrong email' do
        let(:params) { { email: 'wrong email', password: password } }

        it 'renders errors' do
          expect(response).to be_unprocessable
          expect(response).to match_json_schema('errors')
        end
      end

      context 'when wrong password' do
        let(:params) { { email: email, password: 'wrong password' } }

        it 'renders errors' do
          expect(response).to be_unprocessable
          expect(response).to match_json_schema('errors')
        end
      end
    end
  end

  describe 'GET #destroy' do
    include ApiDoc::Sessions::Destroy

    let(:user) { create(:user) }

    before { delete "/account/session", headers: headers }

    describe 'Success' do
      let(:headers) { authorization_header_for(user) }

      it 'flush_session' do
        expect(response).to be_no_content
        expect(response.body).to be_empty
      end
    end

    describe 'Failure' do
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
