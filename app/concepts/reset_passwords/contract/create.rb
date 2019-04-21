# frozen_string_literal: true

module ResetPasswords::Contract
  class Create < Reform::Form
    feature Reform::Form::Dry

    EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze

    property :email, virtual: true
    property :url, virtual: true

    validation do
      required(:email).filled(format?: EMAIL_REGEX)
      required(:url).filled(:str?)
    end
  end
end
