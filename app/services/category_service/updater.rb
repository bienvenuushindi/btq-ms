# frozen_string_literal: true
module CategoryService
  class Updater < BaseService::Updater

    def initialize(resource, params)
      super(resource, params)
    end

    def call
      update_resource
    end

    private

    def update_attributes
      attributes_to_update.each do |attribute_name|
        update_attribute(@resource, attribute_name, @params[attribute_name])
      end
      # add custom handling
    end

    def attributes_to_update
      %i[name description active parent_category_id]
    end
  end
end