# frozen_string_literal: true

module Accounts::Session::Contract
  class Create < Reform::Form
    feature Reform::Form::Dry

    property :password, readable: false, virtual: true
    property :email, virtual: true

    validation :default do
      configure do
        config.namespace = :user_session
      end

      required(:email).filled(:str?)
      required(:password).filled(:str?)
    end
  end
end
