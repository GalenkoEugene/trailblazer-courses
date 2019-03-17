# frozen_string_literal: true

module Accounts::Passwords::Operation
  class Update < Trailblazer::Operation
    step :model

    step Contract::Build(constant: Accounts::Passwords::Contract::Update)
    step Contract::Validate(), fail_fast: true

    step :authenticate
    fail :unauthenticated

    step Contract::Persist()

    step :flush_all_sessions_of_employee
    step :reissue_session
    step :prepare_renderer

    def model(ctx, current_user:, **)
      ctx[:model] = current_user
    end

    def authenticate(ctx, model:, **)
      model.authenticate(ctx['contract.default'].old_password)
    end

    def unauthenticated(ctx, **)
      ctx['contract.default'].errors.add(:base, I18n.t('errors.account.wrong_password'))
    end

    def flush_all_sessions_of_employee(_ctx, model:, **)
      Rails.cache.delete("whitelist_user_token_#{model.id}")
      true
    end

    def reissue_session(ctx, model:, **)
      # create a new session data to return to user
      ctx[:auth] = Auth::Token::Session.generate(model)
    end

    def prepare_renderer(ctx, auth:, **)
      ctx[:model] = nil
      ctx[:renderer_options] = {
        meta: { auth: auth }
      }
    end
  end
end
