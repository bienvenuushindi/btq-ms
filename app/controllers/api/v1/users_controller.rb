class Api::V1::UsersController < ApplicationController
  before_action -> { find_record(User) }, only: %i[show]

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
