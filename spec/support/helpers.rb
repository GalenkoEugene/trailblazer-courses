# frozen_string_literal: true

module Helpers
  def authorization_header_for(user)
    auth = Auth::Token::Session.generate(user)
    allow(Rails).to receive_message_chain(:cache, :read).with(auth_token_key_for(user)) { auth }

    { Authorization: "Bearer #{auth}" }
  end

  def auth_token_key_for(user)
    "whitelist_user_token_#{user.id}"
  end
end
