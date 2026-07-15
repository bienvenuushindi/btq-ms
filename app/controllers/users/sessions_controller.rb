# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include RackSessionsFix
  include JsonResponseHelper
  include CustomSerializer
  respond_to :json

  private

  def respond_with(current_user, _opts = {})
     render json: serialize_resource(current_user, UserSerializer), status: :ok
  end

  def respond_to_on_destroy
    if request.headers['Authorization'].present?
      jwt_secret = Rails.application.credentials.devise_jwt_secret_key.presence ||
                   ENV.fetch("DEVISE_JWT_SECRET_KEY", ENV.fetch("devise_jwt_secret_key"))
      jwt_payload = JWT.decode(request.headers['Authorization'].split(' ').last, jwt_secret).first
      current_user = User.find(jwt_payload['sub'])
    end

    if current_user
      render json: completed_response('Logged out successfully.'), status: :ok
    else
      render json: unauthorized_response("Couldn't find an active session."), status: :unauthorized
    end
  end
end
