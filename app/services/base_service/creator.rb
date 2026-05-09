# frozen_string_literal: true
module BaseService
  class Creator < ApplicationService

    def initialize(params)
      @params = params
    end

    def call
      create_record
    rescue ActiveRecord::RecordInvalid => e
      handle_error(e)
      e.record
    end

    def create_record
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def handle_error(exception)
      Rails.logger.error("Error creating record: #{exception.message}")
      # You can customize the response based on the error
      # render json: { error: "Supplier creation failed: #{exception.message}" }, status: :unprocessable_entity
    end
  end
end
