# app/controllers/concerns/error_handler.rb
module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveStorage::IntegrityError, with: :storage_error
    rescue_from StandardError, with: :handle_unexpected_error
  end

  def record_invalid(exception)
    message = exception.message.partition('Validation failed: ').last
    render json: { meta: { message: message } }, status: 401
  end

  def record_not_found(exception)
    model_name = exception.model.constantize.model_name.human
    render json: { "#{model_name}": nil }, status: :not_found
  end

  def storage_error(exception)
    Rails.logger.error("Image storage error: #{exception.message}")
    render json: { error: 'The image could not be stored. Please try again or contact an administrator.' }, status: :service_unavailable
  end

  def handle_unexpected_error(exception)
    Rails.logger.error("Unexpected error: #{exception.message}")
    render json: { error: 'Something went wrong' }, status: :internal_server_error
  end
end
