class ApplicationController < ActionController::API
  # include Pagy::Backend
  include Paginable
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  include JsonResponseHelper
  respond_to :json

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name avatar phone_number role_id])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name avatar phone_number])
  end
end
