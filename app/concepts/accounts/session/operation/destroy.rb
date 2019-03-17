# frozen_string_literal: true

module Accounts::Session::Operation
  class Destroy < Trailblazer::Operation
    step :remove_token_from_whitelist!

    def remove_token_from_whitelist!(ctx, current_user:, **)
      Rails.cache.delete("whitelist_user_token_#{current_user.id}")
    end
  end
end
