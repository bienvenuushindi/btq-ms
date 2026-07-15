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
      permitted_params = params
                         .require(:requisition_product)
                         .permit(:price, :currency, :status, :quantity, :quantity_type, :note, :supplier_id, :expired_date)

      normalize_requisition_product_params(permitted_params)
    end

    def self.normalize_requisition_product_params(permitted_params)
      permitted_params[:status] = normalize_purchase_status(permitted_params[:status]) if permitted_params.key?(:status)

      %i[quantity_type expired_date supplier_id].each do |key|
        permitted_params.delete(key) if null_value?(permitted_params[key])
      end

      permitted_params
    end

    def self.normalize_purchase_status(status)
      case status
      when true, 1, '1', 'true', 'purchased'
        ProductDetailRequisition::PURCHASED_STATUS
      when false, 0, '0', 'false', 'pending'
        ProductDetailRequisition::PENDING_STATUS
      else
        status
      end
    end

    def self.null_value?(value)
      value.nil? || value == 'null' || value == ''
    end
  end

end
