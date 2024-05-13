# frozen_string_literal: true
module CategoryService
  class Retriever < BaseService::Retriever
    def initialize(scope, filter_params)
      @sort_column = %w[name active created_at count_products]
      super(scope, filter_params)
    end

    def call
      apply_filters
      apply_sorting
    end
  end
end