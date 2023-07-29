class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: %i[show]

  def index
    data = UserSerializer.new(User.all)
    render json: data, status: :ok
  end

  def show
    data = UserSerializer.new(set_user)
    render json: data, status: :ok
  end

  private

  def set_user
    User.find(params[:id])
  end
end
