# frozen_string_literal: true
module RequisitionService
  class Remover < BaseService::Remover
    def self.remove_item(requisition, product_detail_id)
      product_detail = ProductDetail.find(product_detail_id)
      ProductDetailRequisition.where(requisition: requisition, product_detail: product_detail).destroy_all
    end
  end
end