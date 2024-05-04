# frozen_string_literal: true
module ProductService
  class StatusCounter < ApplicationService
    def call
      count_by_status
    end

    private
    def count_by_status
      active_count = Product.count_by_status(true)
      inactive_count = Product.count_by_status(false)

      { active: active_count, inactive: inactive_count }
    end
  end
end