class Api::V1::CurrentUserController < ApplicationController
  def index
    data = serialize_resource(current_user, serializer)
    render json: data, status: :ok
  end

  private

  def serializer
    UserSerializer
  end
end
