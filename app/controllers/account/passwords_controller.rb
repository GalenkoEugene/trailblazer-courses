# frozen_string_literal: true

module Account
  class PasswordsController < AuthorizedController
    def update
      endpoint Accounts::Passwords::Operation::Update, payload: payload, current_user: current_user
    end
  end
end
