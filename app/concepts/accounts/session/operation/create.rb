# frozen_string_literal: true

module Accounts::Session::Operation
  class Create < Trailblazer::Operation
    pass Macro::Semantic(success: :created)

    step Contract::Build(constant: Accounts::Session::Contract::Create)
    step Contract::Validate(), fail_fast: true

    step Model(User, :find_by, :email)
    step :authenticate
    fail :render_errors

    step :set_token!
    step :set_whitelist_key!
    step :whitelist_token!
    step :prepare_renderer

    def authenticate(ctx, model:, params:, **)
      model.authenticate(params[:password])
    end

    def render_errors(ctx, *)
      ctx[:errors] = { base: [I18n.t('.errors.session.validation')] }
    end

    def set_token!(ctx, model:, **)
      ctx[:auth] = Auth::Token::Session.generate(model)
    end

    def set_whitelist_key!(ctx, model:, **)
      ctx[:whitelist_key] = "whitelist_user_token_#{model.id}".freeze
    end

    def whitelist_token!(ctx, auth:, **)
      Rails.cache.write(ctx[:whitelist_key], auth.to_s, expires_in: Auth::Token::Session::EXPIRATION_TIME)
    end

    def prepare_renderer(ctx, auth:, **)
      ctx[:model] = nil
      ctx[:renderer_options] = {
        meta: { auth: auth }
      }
    end
  end
end
