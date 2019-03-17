# frozen_string_literal: true

module Account
  class SessionsController < ApplicationController
    before_action :authorize_request!, except: :create

    def create
      endpoint Accounts::Session::Operation::Create
    end

    def destroy
      endpoint Accounts::Session::Operation::Destroy, current_user: current_user
    end
  end
end
