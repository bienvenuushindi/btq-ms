# frozen_string_literal: true
module ProductDetailService
  module Helper
    def self.index_options
      { fields: { product_detail: %i[id size expired_date dozen_units box_units created_at image_urls status approval_status product_name supplier_status shop_prices] } }
    end

    def self.expiring_soon_options
      { fields: { product_detail: %i[id product_id size expired_date product_name image_urls supplier_status shop_prices] } }
    end

    def self.suppliers_options
      { fields: { product_detail: [:suppliers] } }
    end

    def self.product_detail_params(params)
      params.require(:product_detail).permit(:size, :expired_date, :dozen_units, :box_units, :approval_status, :rejection_reason, :tags, images: [])
      # .merge(product_id: params[:product_id])
    end
  end
end
