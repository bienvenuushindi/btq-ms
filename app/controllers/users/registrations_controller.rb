# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  include RackSessionsFix
  include JsonResponseHelper
  respond_to :json

  private

  def respond_with(current_user, _opts = {})
    if resource.persisted?
      data = UserSerializer.new(current_user).serializable_hash[:data][:attributes]
      message = 'Signed up successfully.'
      render json: created_response(data, message), status: :created
    else
      render json: error_response(current_user), status: :unprocessable_entity
    end
  end
end
