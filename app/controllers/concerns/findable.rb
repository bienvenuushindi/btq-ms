# frozen_string_literal: true

module Findable
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  end

  private

  def find_record(model_class)
    record = model_class.find(params[:id])
    instance_variable_set("@#{model_class.name.downcase}", record)
  end

  def record_not_found(exception)
    model_name = exception.model.constantize.model_name.human.titleize
    render json: { data: {}, message: "#{model_name} not found" }, status: :not_found
  end
end
