# frozen_string_literal: true

module Lib::TokenCreator
  class UserInvitation
    DEFAULT_TOKEN_EXPIRATION = 24.hours

    def self.call(ctx, model:, **)
      ctx[:token] = ::Service::JWTAdapter.encode(
        aud: 'user_invitation',
        sub: model.id,
        exp: DEFAULT_TOKEN_EXPIRATION.from_now.to_i
      )
    end
  end
end
