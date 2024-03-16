class Api::V1::UsersController < ApplicationController
  before_action -> { find_record(User) }, only: %i[show]

  def index
    render json: serialize_resources(User.all, serializer), status: :ok
  end

  def show
    render json: serialize_resource(@user, serializer), status: :ok
  end

  private

  def serializer
    UserSerializer
  end
end
