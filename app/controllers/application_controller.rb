class ApplicationController < ActionController::API
  # include Pagy::Backend
  include Paginable
  include UtilitiesHelper
  include JsonResponseHelper
  include Findable
  include ParameterMissingHandling
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  respond_to :json

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name avatar phone_number role_id])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name avatar phone_number])
  end

  def serialize_resource(resource, serializer_class)
    serializer_class.new(resource).serializable_hash[:data][:attributes]
  end

  def serialize_resources(resources, serializer_class)
    serializer_class.new(resources).serializable_hash[:data].map { |data| data[:attributes] }
  end
end
