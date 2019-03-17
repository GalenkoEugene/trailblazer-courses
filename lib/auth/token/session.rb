# frozen_string_literal: true

module Auth
  module Token
    class Session
      SESSION_AUD_CLAIM = 'session'
      EXPIRATION_TIME = 1.day

      class << self
        def generate(user)
          Service::JWTAdapter.encode(
            aud: SESSION_AUD_CLAIM,
            sub: user.id,
            exp: (Time.current + EXPIRATION_TIME).to_i
          )
        end

        def find_user_by_token(token)
          token = Service::JWTAdapter.decode(token, aud: SESSION_AUD_CLAIM, verify_aud: true)
          User.find_by(id: token.first['sub'])
        rescue JWT::ExpiredSignature, JWT::InvalidAudError, JWT::DecodeError
          nil
        end
      end
    end
  end
end
