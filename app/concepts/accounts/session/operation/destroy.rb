# frozen_string_literal: true

module Accounts::Session::Operation
  class Destroy < Trailblazer::Operation
    step :flush_session!

    def flush_session!(ctx, payload:, **)
      session = JWTSessions::Session.new
      session.flush_by_uid(payload['ruid'])
    end
  end
end
