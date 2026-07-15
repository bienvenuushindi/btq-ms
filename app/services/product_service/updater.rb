# frozen_string_literal: true
module ProductService
  class Updater < BaseService::Updater
    include CategoryHelper

    def initialize(resource, params, current_user = nil)
      @current_user = current_user
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
      update_approval_status
      add_categories(@resource, @params)
    end

    def attributes_to_update
      %i[name short_description description country_origin tags images]
    end

    def update_approval_status
      return unless @current_user&.admin?
      return unless @params[:approval_status].present?

      case @params[:approval_status].to_s
      when 'approved'
        @resource.approve!(@current_user)
      when 'rejected'
        @resource.reject!(@current_user, @params[:rejection_reason])
      else
        update_attribute(@resource, :approval_status, @params[:approval_status])
      end
    end
  end
end
