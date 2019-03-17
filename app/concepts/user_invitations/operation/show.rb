# frozen_string_literal: true

module UserInvitations::Operation
  class Show < Trailblazer::Operation
    pass Macro::Semantic(failure: :gone)

    step Contract::Build(constant: UserInvitations::Contract::Token)
    step Contract::Validate()

    step Rescue(JWT::InvalidAudError, JWT::DecodeError) {
      step :token_valid?
    }

    def token_valid?(ctx, **)
      Service::JWTAdapter.decode(ctx['contract.default'].token, aud: 'user_invitation', verify_aud: true)
    end
  end
end
