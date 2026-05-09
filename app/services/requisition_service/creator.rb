# frozen_string_literal: true
module RequisitionService
  class Creator < BaseService::Creator
    def initialize(params, current_user)
      @current_user = current_user
      super(params)
    end

    def self.add_products(resource, params)
      product_detail_ids = params.require(:requisition).fetch(:product_detail_ids, []).map(&:to_i)
      existing_product_detail_ids = resource.product_details.where(id: product_detail_ids).pluck(:id)
      new_product_detail_ids = product_detail_ids - existing_product_detail_ids
      new_product_detail_ids.each do |product_detail_id|
        ProductDetailRequisition.create!(
          requisition: resource,
          product_detail_id: product_detail_id,
          status: false
        )
      end
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
        date: @params[:date],
        price_currency: @params[:currency]
      )
    end
  end
end
