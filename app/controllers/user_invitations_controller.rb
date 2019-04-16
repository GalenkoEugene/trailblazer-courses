# frozen_string_literal: true

class UserInvitationsController < ApplicationController
  before_action :authorize_access_request!, only: :create

  def show
    endpoint UserInvitations::Operation::Show
  end

  def create
    endpoint UserInvitations::Operation::Create, current_user: current_user
  end
end
