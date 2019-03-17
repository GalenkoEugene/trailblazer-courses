# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users, only: %i[index destroy create]
  resource :reset_password, only: %i[show create update]
  resource :user_invitation, only: %i[show create]
  namespace :account do
    resource :password, only: :update
    resource :session, only: %i[create destroy]
  end
end
