class Api::V1::CurrentUserController < ApplicationController
  def index
    data = serialize_resource(current_user, serializer)
    render json: data, status: :ok
  end

  def accept_terms
    current_user.update!(terms_accepted_at: Time.current, terms_version: User::TERMS_VERSION)
    render json: serialize_resource(current_user, serializer), status: :ok
  end

  private

  def serializer
    UserSerializer
  end
end
