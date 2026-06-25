module ProductService
  class Retriever < BaseService::Retriever
    def initialize(scope, filter_params)
      @sort_column = %w[name active created_at country_origin]
      super(scope, filter_params)
    end

    def call
      apply_filters
      apply_sorting
      attach_images_to_result
    end

    private

    def attach_images_to_result
      @scope.includes(:categories, :tags, :product_details).with_attached_images
    end

  end
end
