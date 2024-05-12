# frozen_string_literal: true
module BaseService
  class Reader < ApplicationService
    def initialize(resource_class, resource_id)
      @resource_class = resource_class
      @resource_id = resource_id
    end

    def call
      find_resource
    end

    protected
    def find_resource
      @resource_class.find_by(id: @resource_id)
    end
  end
end