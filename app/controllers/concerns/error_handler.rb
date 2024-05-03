# frozen_string_literal: true

module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
    rescue_from StandardError, with: :handle_unexpected_error
  end

  def handle_validation_error(exception)
    # Handle validation errors
    Rails.logger.error("Validation error: #{exception.message}")
    # Add more specific error handling or notifications if needed
    render json: { error: exception.message }, status: :unprocessable_entity
  end

  def handle_unexpected_error(exception)
    # Handle unexpected errors
    Rails.logger.error("Unexpected error: #{exception.message}")
    # Add more specific error handling or notifications if needed
    render json: { error: 'Something went wrong' }, status: :internal_server_error
  end
end
