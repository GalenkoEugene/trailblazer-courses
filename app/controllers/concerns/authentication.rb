# frozen_string_literal: true

module Authentication
  def self.included(base)
    base.class_eval do
      rescue_from UnauthorizedError do
        exception_respond(:unauthorized, I18n.t('errors.unauthenticated'))
      end
    end
  end

  def authorize_request!
    @auth_token = (request.headers['Authorization'] || '').split(' ').last
    raise UnauthorizedError if auth_token.blank? || whitelisted_token.blank?
  end

  def current_user
    @current_user ||= Auth::Token::Session.find_user_by_token(auth_token)
  end

  private

  attr_reader :auth_token

  def whitelisted_token
    Rails.cache.read("whitelist_user_token_#{current_user.id}")
  end

  def exception_respond(status, message)
    errors = { base: [message] }

    render jsonapi_errors: errors,
           class: { Hash: Lib::Representer::HashErrorsSerializer },
           status: status
  end

  class UnauthorizedError < StandardError; end
end
