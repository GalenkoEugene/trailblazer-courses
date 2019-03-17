# frozen_string_literal: true

RSpec.describe 'Users', :dox, type: :request do
  include ApiDoc::Users::Api

  describe 'GET #index' do
    include ApiDoc::Users::Index

    let(:params) { { page: page } }
    let(:headers) { authorization_header_for(current_user) }
    let(:current_user) { create(:user, is_admin: is_admin) }
    let(:is_admin) { true }
    let(:page) { 2 }

    before do
      create_list(:user, 7)
      stub_const('Pagy::VARS', Pagy::VARS.merge(items: 2))
      get '/users', params: params, headers: headers
    end

    describe 'Success' do
      it 'renders paginated list of users' do
        expect(JSON.parse(response.body)['data'][0]['type']).to eq('users')
        expect(response).to be_ok
        expect(response).to match_json_schema('users/index')
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

      context 'when current_user is not an administrator' do
        let(:is_admin) { false }

        it 'returns forbidden status' do
          expect(response).to be_forbidden
          expect(response.body).to be_empty
        end
      end

      context 'when page is not valid' do
        let(:page) { 'wrong' }

        it 'renders errors' do
          expect(response).to be_unprocessable
          expect(response).to match_json_schema('errors')
        end
      end

      context 'when page is out of limits' do
        let(:page) { 9999 }

        it 'renders errors' do
          expect(response).to be_unprocessable
          expect(response).to match_json_schema('errors')
        end
      end
    end
  end

  describe 'GET #destroy' do
    include ApiDoc::Users::Index

    let(:headers) { authorization_header_for(current_user) }
    let(:current_user) { create(:user, is_admin: is_admin) }
    let(:is_admin) { true }
    let(:target_user) { create(:user) }
    let(:target_user_id) { target_user.id }

    before do
      delete "/users/#{target_user_id}", headers: headers
    end

    describe 'Success' do
      it 'renders paginated list of users' do
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

      context 'when current_user is not an administrator' do
        let(:is_admin) { false }

        it 'returns forbidden status' do
          expect(response).to be_forbidden
          expect(response.body).to be_empty
        end
      end

      context 'when triyng remove self' do
        let(:target_user_id) { current_user.id }

        it 'renders errors' do
          expect(response).to be_unprocessable
          expect(response).to match_json_schema('errors')
        end
      end
    end
  end

  describe 'POST #create' do
    include ApiDoc::Users::Create

    let(:user_params) { build(:user) }
    let(:first_name) { user_params.first_name }
    let(:last_name) { user_params.last_name }
    let(:password) { user_params.password }
    let(:password_confirmation) { user_params.password }
    let(:user_invitation) { create(:user_invitation) }
    let(:token) { Service::JWTAdapter.encode(aud: 'user_invitation', sub: user_invitation.id, exp: 1.day.from_now.to_i) }
    let(:params) do
      {
        token: token,
        first_name: first_name,
        last_name: last_name,
        password: password,
        password_confirmation: password_confirmation
      }
     end

    before { post '/users', params: params, as: :json }

    describe 'Success' do
      let(:current_user) { admin }

      it 'create user by token', :dox do
        expect(response).to be_created
        expect(response.body).to be_empty
      end
    end

    describe 'Fail' do
      shared_examples 'render errors' do
        it 'renders errors', :dox do
          expect(response).to be_unprocessable
          expect(response).to match_json_schema('errors')
        end
      end

      context 'when first_name blank' do
        it_behaves_like 'render errors' do
          let(:first_name) { { first_name: '' } }
        end
      end

      context 'when last_name blank' do
        it_behaves_like 'render errors' do
          let(:last_name) { { last_name: '' } }
        end
      end

      context 'when password blank' do
        it_behaves_like 'render errors' do
          let(:password) { { password: '' } }
        end
      end

      context 'when password confirmation does not match' do
        it_behaves_like 'render errors' do
          let(:password) { { password: 'Password1' } }
          let(:password_confirmation) { { password: 'Password2' } }
        end
      end
    end
  end
end
