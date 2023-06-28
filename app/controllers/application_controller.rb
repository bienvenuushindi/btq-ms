class ApplicationController < ActionController::API
  respond_to :json
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!

  def authenticate_user!
    render json: { error: 'Not Authorized' }, status: :unauthorized unless user_signed_in? || request.method == 'POST'
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name avatar phone_number role_id])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name avatar phone_number])
  end
end
