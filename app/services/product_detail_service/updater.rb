# frozen_string_literal: true
module ProductDetailService
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
      %i[size expired_date unit_price dozen_price box_price box_units dozen_units currency status images tags]
    end
  end
end