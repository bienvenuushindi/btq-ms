# frozen_string_literal: true
module CategoryService
  class Reader < BaseService::Reader
    def initialize(resource_id)
      super(Category, resource_id)
    end
  end
end