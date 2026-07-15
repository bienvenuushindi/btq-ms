module ProductService
  class Retriever < BaseService::Retriever
    def initialize(scope, filter_params)
      @sort_column = %w[name active created_at country_origin]
      super(scope, filter_params)
    end

    def call
      apply_filters
      apply_category_filter
      apply_sorting
      attach_images_to_result
    end

    private

    def apply_category_filter
      category_ids = Array(@params[:category_ids].presence || @params[:category_id]).compact_blank
      return if category_ids.empty?

      product_ids = Product.joins(:categories).where(categories: { id: category_ids }).select(:id)
      @scope = @scope.where(id: product_ids)
    end

    def attach_images_to_result
      @scope.with_attached_images
    end

  end
end
