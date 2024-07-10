# frozen_string_literal: true
module ProductService
class Remover < BaseService::Remover
def initialize(resource_id)
      super(Product,resource_id)
    end
end
end
