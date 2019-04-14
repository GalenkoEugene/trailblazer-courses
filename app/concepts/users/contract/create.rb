# frozen_string_literal: true

module User::Contract
  class Create < Reform::Form
    feature Reform::Form::Dry

    property :token, virtual: true
    property :email
    property :first_name
    property :last_name
    property :password, readable: false
    property :password_confirmation, virtual: true

    validation do
      configure do
        config.namespace = :create_user

        def unique?(value)
          !User.exists?(email: value)
        end
      end

      required(:token).filled(:str?)
      required(:email).filled(:str?, :unique?)
      required(:first_name).filled(:str?)
      required(:last_name).filled(:str?)
      required(:password).filled(
        :str?,
        format?: Constants::Shared::PASSWORD_REGEX,
        min_size?: Constants::Shared::PASSWORD_MIN_LENGTH
      ).confirmation
    end
  end
end
