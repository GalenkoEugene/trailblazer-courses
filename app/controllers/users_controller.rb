# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authorize_request!, except: :create

  def index
    endpoint Users::Operation::Index, current_user: current_user
  end

  def create
    endpoint Users::Operation::Create
  end

  def destroy
    endpoint Users::Operation::Destroy, current_user: current_user
  end
end
