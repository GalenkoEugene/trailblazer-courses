# frozen_string_literal: true

class UserMailer < ApplicationMailer
  default site: 'example.stub'

  def reset_password(user, token)
    @user = user
    @link = token_link(token, :reset_password)
    mail(to: @user.email,
         subject: I18n.t('user_mailer.reset_password.subject'))
  end

  def invite_user(user, token)
    @user = user
    @link = token_link(token, :user_invitation)
    mail(to: @user.email,
         subject: I18n.t('user_mailer.invite_user.subject'))
  end

  private

  def token_link(token, path)
    URI.parse("#{Rails.application.config.client_url}/#{path}?token=#{token}").to_s
  end
end
