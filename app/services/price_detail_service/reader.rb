# frozen_string_literal: true
module PriceDetailService
  class Reader < BaseService::Reader
    def initialize(resource_id)
      super(PriceDetail, resource_id)
    end
  end
end