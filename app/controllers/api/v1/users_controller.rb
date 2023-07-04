class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: %i[show]

  def index
    render json: fetch_response(User.all), status: :ok
  end

  def show
    render json: fetch_response(set_user), status: :ok
  end

  private

  def set_user
    User.find(params[:id])
  end
end
