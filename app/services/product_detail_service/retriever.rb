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

    def self.expired_soon(params)
       limit = params.fetch(:limit, 5)
       ProductDetail.last_soon_expired(limit)
    end

    def self.expired(params)
       limit = params.fetch(:limit, 5)
       ProductDetail.last_expired(limit)
    end


    private

    def attach_images_to_result
      @scope.includes(:product, :price_details, :suppliers, :tags).with_attached_images
    end
  end
end
