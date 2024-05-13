# frozen_string_literal: true
module RequisitionService
  module Helper
    def self.index_options
      { fields: { requisition: %i[id total_price count_products count_products_bought price_currency archived date] } }
    end

    def self.requisition_params(params)
      params.require(:requisition).permit(:date, :currency, product_detail_ids: [])
    end

    def self.update_requisition_params(params)
      params.require(:requisition_product).permit(:price, :currency, :status, :quantity, :quantity_type, :note, :supplier_id, :expired_date)
    end
  end

end
