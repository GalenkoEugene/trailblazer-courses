# frozen_string_literal: true

module Users::Operation
  class Create < Trailblazer::Operation
    step Model(User, :new)
    step Rescue(JWT::InvalidAudError, JWT::DecodeError) {
      step :extend_params!
    }

    step Contract::Build(constant: User::Contract::Create)
    step Contract::Validate(), fail_fast: true
    step Contract::Persist()

    def extend_params!(ctx, **)
      body, = Service::JWTAdapter.decode(ctx[:params][:token],
                                         aud: 'user_invitation',
                                         verify_aud: true)

      invitation_email = UserInvitation.find_by(id: body['sub']).email
      ctx[:params] = ctx[:params].merge(email: invitation_email)
    end
  end
end
