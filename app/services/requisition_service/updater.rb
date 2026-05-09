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
        @record.decrement_total_price
        if @record.update(RequisitionService::Helper.update_requisition_params(@params))
          update_price_detail
        end
      end
    end

    private
    def update_price_detail
      price_params = RequisitionService::Helper.update_requisition_params(@params)
      price = price_params[:price]
      currency = price_params[:currency]
      supplier_id = price_params[:supplier_id]
      product_detail_id = @params[:product_detail_id]
      quantity_type = price_params[:quantity_type]
      PriceDetail.custom_upsert({ quantity_type => price }, currency, supplier_id, product_detail_id)
    end
  end

end