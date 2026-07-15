class ApplicationController < ActionController::API
  include Paginable
  include UtilitiesHelper
  include JsonResponseHelper
  include ParameterMissingHandling
  include CustomSerializer
  include ErrorHandler

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  respond_to :json

  def routing_error
    render json: { error: 'Route not found' }, status: :not_found
  end

  def render_serialized_resource(resource, serializer, status, options = {})
    if resource&.persisted?
      render json: serialize_resource(resource, serializer, options), status: status
    else
      render json: resource ? error_response(resource) : { status: { code: 422, message: 'The request could not be completed.' } }, status: :unprocessable_entity
    end
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

end
