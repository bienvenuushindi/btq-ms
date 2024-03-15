# frozen_string_literal: true

module ParameterMissingHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActionController::ParameterMissing, with: :parameter_missing
  end

  private

  def parameter_missing(exception)
    render json: { error: "Parameter missing: #{exception.param}" }, status: :bad_request
  end
end