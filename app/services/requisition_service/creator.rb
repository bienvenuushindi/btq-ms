# frozen_string_literal: true
module RequisitionService
  class Creator < BaseService::Creator
    def initialize(params, current_user)
      @current_user = current_user
      super(params)
    end

    def self.add_products(resource, params)
      product_detail_ids = params.fetch(:product_detail_ids, [])
      existing_product_detail_ids = resource.product_details.where(id: product_detail_ids).pluck(:id)
      new_product_detail_ids = product_detail_ids - existing_product_detail_ids
      new_product_details = ProductDetail.where(id: new_product_detail_ids)
      resource.product_details << new_product_details
      resource
    end

    private

    def create_record
      @requisition = build_requisition
      @requisition.save!

      @requisition
    end

    def build_requisition
      Requisition.new(
        user: @current_user,
        date: requisition_params[:date],
        price_currency: requisition_params[:currency]
      )
    end
  end
end
