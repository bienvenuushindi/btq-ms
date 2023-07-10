# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include RackSessionsFix
  include JsonResponseHelper
  respond_to :json

  private

  def respond_with(current_user, _opts = {})
    data = { user: UserSerializer.new(current_user).serializable_hash[:data][:attributes] }
    message = 'Logged in successfully.'
    render json: created_response(data, message), status: :ok
  end

  def respond_to_on_destroy
    if request.headers['Authorization'].present?
      jwt_payload = JWT.decode(request.headers['Authorization'].split(' ').last, Rails.application.credentials.devise_jwt_secret_key!).first
      current_user = User.find(jwt_payload['sub'])
    end

    if current_user
      render json: completed_response('Logged out successfully.'), status: :ok
    else
      render json: unauthorized_response("Couldn't find an active session."), status: :unauthorized
    end
  end
end
