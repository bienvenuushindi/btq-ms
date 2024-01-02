class Api::V1::CurrentUserController < ApplicationController
  def index
    data = serializer.new(current_user)
    render json: data, status: :ok
  end

  def serializer
    UserSerializer
  end
end
