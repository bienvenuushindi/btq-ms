# frozen_string_literal: true
module RequisitionService
  class Updater < BaseService::Updater
    def initialize(resource, params)
      super(resource, params)
    end

    def call
      update_resource
    end

    private

    def update_attributes
      @record = @resource.product_detail_requisitions.find_by(product_detail_id: @params[:product_detail_id])
      if @record
        price_params = RequisitionService::Helper.update_requisition_params(@params)
        @record.decrement_total_price
        if @record.update(price_params)
          update_purchased_count
        end
      end
    end
    def update_purchased_count
      @resource.update!(
        count_products_bought: @resource.product_detail_requisitions.bought.count
      )
    end
  end

end
