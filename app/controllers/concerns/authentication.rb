# frozen_string_literal: true

module Authentication
  def self.included(base)
    base.class_eval do
      rescue_from JWTSessions::Errors::Unauthorized do
        exception_respond(:unauthorized, I18n.t('errors.unauthenticated'))
      end
    end
  end

  def current_user
    @current_user ||= User.find(payload['user_id'])
  end

  private

  def exception_respond(status, message)
    errors = { base: [message] }

    render jsonapi_errors: errors,
           class: { Hash: Lib::Representer::HashErrorsSerializer },
           status: status
  end
end
