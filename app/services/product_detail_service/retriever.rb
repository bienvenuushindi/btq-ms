# frozen_string_literal: true
module ProductDetailService
  class Retriever < BaseService::Retriever
    def initialize(scope, filter_params)
      @sort_column = %w[created_at]
      super(scope, filter_params)
    end


    def call
      apply_filters
      apply_sorting
      attach_images_to_result
    end

    def self.expired_soon(params, scope = ProductDetail.all)
       scope = scope.details_with_product_name.sc_expired_soon
       params[:limit].present? ? scope.limit(params[:limit]) : scope
    end

    def self.expired(params, scope = ProductDetail.all)
       scope = scope.details_with_product_name.sc_expired
       params[:limit].present? ? scope.limit(params[:limit]) : scope
    end


    private

    def attach_images_to_result
      @scope.with_attached_images
    end
  end
end
