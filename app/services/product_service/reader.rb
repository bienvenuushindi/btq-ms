# frozen_string_literal: true
module ProductService
  class Reader < BaseService::Reader
    def initialize(resource_id)
      super(Product, resource_id)
    end
  end
end