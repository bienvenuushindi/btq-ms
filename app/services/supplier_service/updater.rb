# frozen_string_literal: true
module SupplierService
  class Updater < BaseService::Updater
    include CategoryHelper

    def initialize(resource, params)
      super(resource, params)
    end

    private

    def update_attributes
      attributes_to_update.each do |attribute_name|
        update_attribute(@resource, attribute_name, @params[attribute_name])
      end
      update_attribute(@resource, :address, @params)
      add_categories(@resource, @params)
    end

    def attributes_to_update
      %i[shop_name tags images]
    end
  end
end