# frozen_string_literal: true
module SupplierService
  class Reader < BaseService::Reader
    def initialize(resource_id)
      super(Supplier, resource_id)
    end
  end
end