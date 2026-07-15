# frozen_string_literal: true
module RequisitionService
  class Creator < BaseService::Creator
    def initialize(params, current_user)
      @current_user = current_user
      super(params)
    end

    def self.add_products(resource, params)
      product_detail_ids = params.require(:requisition).fetch(:product_detail_ids, []).map(&:to_i)
      approved_product_detail_ids = ProductDetail.visible_catalog.where(id: product_detail_ids).pluck(:id)
      rejected_product_detail_ids = product_detail_ids - approved_product_detail_ids
      if rejected_product_detail_ids.any?
        resource.errors.add(:base, 'Only approved product details can be added to a requisition')
        return resource
      end

      existing_product_detail_ids = resource.product_details.where(id: approved_product_detail_ids).pluck(:id)
      new_product_detail_ids = product_detail_ids - existing_product_detail_ids
      buyer_supplier = resource.user&.suppliers&.order(:created_at)&.first
      new_product_detail_ids.each do |product_detail_id|
        ProductDetailRequisition.create!(
          requisition: resource,
          product_detail_id: product_detail_id,
          buyer_supplier: buyer_supplier,
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
