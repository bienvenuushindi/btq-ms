# frozen_string_literal: true
module BaseService
class Remover < ApplicationService
def initialize(resource_class, resource_id)
      @resource_class = resource_class
      @resource_id = resource_id
    end

    def call
      remove_resource
    end

    private

    def remove_resource
      resource = @resource_class.find_by(id: @resource_id)
      return false unless resource

      resource.destroy
      true
    end
end
end
