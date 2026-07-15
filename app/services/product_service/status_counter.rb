# frozen_string_literal: true
module ProductService
  class StatusCounter < ApplicationService
    def initialize(current_user = nil)
      @current_user = current_user
    end

    def call
      count_by_status
    end

    private
    def count_by_status
      return Product.supplier_counts(@current_user) if @current_user&.supplier?

      public_details = ProductDetail.joins(:product).merge(Product.public_reviewable)
      active_count = public_details.active.count
      inactive_count = public_details.inactive.count
      { active: active_count, inactive: inactive_count, market: ProductDetail.visible_catalog.count }
    end
  end
end
