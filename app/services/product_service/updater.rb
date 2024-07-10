# frozen_string_literal: true
module ProductService
  class Updater < BaseService::Updater
    include CategoryHelper

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
      add_categories(@resource, @params)
    end

    def attributes_to_update
      %i[name short_description description active country_origin tags images]
    end
  end
end