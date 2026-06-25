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
      attach_images_to_result
    end

    private

    def attach_images_to_result
      @scope.with_attached_image
    end
  end
end
