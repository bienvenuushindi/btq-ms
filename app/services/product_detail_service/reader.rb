# frozen_string_literal: true
module ProductDetailService
  class Reader < BaseService::Reader
    def initialize(resource_id)
      super(ProductDetail, resource_id)
    end
  end
end