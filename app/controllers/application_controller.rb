class ApplicationController < ActionController::API
  # include Pagy::Backend
  include Paginable
  include UtilitiesHelper
  include JsonResponseHelper
  include ParameterMissingHandling
  include CustomSerializer
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  respond_to :json

  def routing_error
    render json: { error: 'Route not found' }, status: :not_found
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name avatar phone_number role_id])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name avatar phone_number])
  end

  def find_record(model_class)
    record = model_class.find(params[:id])
    instance_variable_set("@#{model_class.name.downcase}", record)
  end

  def record_not_found(exception)
    model_name = exception.model.constantize.model_name.human
    render json: { "#{model_name}": nil}, status: :not_found
  end
end
