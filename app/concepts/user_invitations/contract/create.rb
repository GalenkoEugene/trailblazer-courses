# frozen_string_literal: true

module UserInvitations::Contract
  class Create < Reform::Form
    feature Reform::Form::Dry

    property :email

    validation do
      configure do
        config.namespace = :user_email
      end

      required(:email).filled(format?: ResetPasswords::Contract::Create::EMAIL_REGEX)
    end
  end
end
