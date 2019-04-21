# frozen_string_literal: true

class UserMailer < ApplicationMailer
  default site: 'example.stub'

  def reset_password(user, url, token)
    @user = user
    @link = token_link(token, url)
    mail(to: @user.email,
         subject: I18n.t('user_mailer.reset_password.subject'))
  end

  def invite_user(user, url, token)
    @user = user
    @link = token_link(token, url)
    mail(to: @user.email,
         subject: I18n.t('user_mailer.invite_user.subject'))
  end

  private

  def token_link(token, url)
    URI.parse("#{url}?token=#{token}").to_s
  end
end
