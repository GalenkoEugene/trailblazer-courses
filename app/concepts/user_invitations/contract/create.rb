# frozen_string_literal: true

module UserInvitations::Contract
  class Create < Reform::Form
    feature Reform::Form::Dry

    property :email
    property :url, virtual: true

    validation do
      configure do
        config.namespace = :user_email

        def unique?(value)
          !User.exists?(email: value)
        end
      end

      required(:url).filled(:str?)
      required(:email).filled(
        :str?,
        :unique?,
        format?: ResetPasswords::Contract::Create::EMAIL_REGEX)
    end
  end
end
