# frozen_string_literal: true

FactoryBot.define do
  factory :user_invitation do
    email { FFaker::Internet.email }
  end
end
