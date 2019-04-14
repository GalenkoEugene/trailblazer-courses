# frozen_string_literal: true

module UserInvitations::Operation
  class Create < Trailblazer::Operation
    step Policy::Guard(Lib::Policy::AdministratorGuard.new), fail_fast: true
    pass Macro::Semantic(success: :created)

    step :check_user_existence?
    fail :user_existence_error

    step Model(UserInvitation, :new)
    step Contract::Build(constant: UserInvitations::Contract::Create)
    step Contract::Validate(), fail_fast: true
    step Contract::Persist()

    step :send_user_invitation

    def check_user_existence?(ctx, params:, **)
      !User.where(email: params[:email]).exists?
    end

    def user_existence_error(ctx, **)
      ctx[:errors] = { base: [I18n.t('errors.user_invitations.already_exists')] }
    end

    def send_user_invitation(_ctx, model:, **)
      token = Lib::Service::TokenCreator::UserInvitation.call(model)
      UserMailer.invite_user(model, token).deliver_later
    end
  end
end
