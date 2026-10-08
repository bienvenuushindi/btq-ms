# frozen_string_literal: true
module SupplierService
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
      update_attribute(@resource, :address, @params)
      add_categories(@resource, @params)
      update_user
    end

    def attributes_to_update
      %i[shop_name tags images]
    end

    def update_user
      attributes = @params.slice(:name, :email, :phone_number, :active).compact
      @resource.user.update!(attributes) if attributes.present?
    end
  end
end
