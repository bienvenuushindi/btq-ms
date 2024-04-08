# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  include RackSessionsFix
  include JsonResponseHelper
  respond_to :json
  include CustomSerializer

  private


  def sign_up_params
    params.require(:user).permit(:email, :password, :name, :phone_number, :role_id)
  end

  def account_update_params
    params.require(:user).permit(:email, :password, :name, :phone_number, :role_id)
  end

  def respond_with(current_user, _opts = {})
    if resource.persisted?
       render json: serialize_resource(current_user, UserSerializer), status: :created
    else
      render json: error_response(current_user), status: :unprocessable_entity
    end
  end
end
