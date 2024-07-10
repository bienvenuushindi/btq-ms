# frozen_string_literal: true
module RequisitionService
  class Retriever < BaseService::Retriever
    def initialize(scope, filter_params)
      @sort_column = %w[created_at]
      super(scope, filter_params)
    end

    def call
      apply_filters
      apply_sorting
    end
  end
end