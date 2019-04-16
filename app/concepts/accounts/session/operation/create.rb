# frozen_string_literal: true

module Accounts::Session::Operation
  class Create < Trailblazer::Operation
    pass Macro::Semantic(success: :created)

    step Contract::Build(constant: Accounts::Session::Contract::Create)
    step Contract::Validate(), fail_fast: true

    step Model(User, :find_by, :email)
    step :authenticate
    fail :render_errors

    step :login!
    step :prepare_renderer

    def authenticate(ctx, model:, params:, **)
      model.authenticate(params[:password])
    end

    def render_errors(ctx, *)
      ctx[:errors] = { base: [I18n.t('.errors.session.validation')] }
    end

    def login!(ctx, model:, **)
      ctx[:auth] = JWTSessions::Session.new(
        payload: { user_id: model.id },
        namespace: "user-sessions-#{model.id}"
      ).login
    end

    def prepare_renderer(ctx, auth:, **)
      ctx[:model] = nil
      ctx[:renderer_options] = {
        meta: { auth: auth }
      }
    end
  end
end
