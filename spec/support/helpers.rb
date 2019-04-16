# frozen_string_literal: true

module Helpers
  def authorization_header_for(user)
    session = JWTSessions::Session.new(payload: { user_id: user.id },
                                       refresh_by_access_allowed: true)

    { Authorization: "Bearer #{session.login[:access]}" }
  end
end
