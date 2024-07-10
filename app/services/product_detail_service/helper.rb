# frozen_string_literal: true
module ProductDetailService
  module Helper
    def self.index_options
      { fields: { product_detail: %i[id size currency expired_date dozen_units box_units created_at image_urls status product_name] } }
    end

    def self.expiring_soon_options
      { fields: { product_detail: %i[:id size expired_date product_name image_urls] } }
    end

    def self.suppliers_options
      { fields: { product_detail: [:suppliers] } }
    end

    def self.product_detail_params(params)
      params.require(:product_detail).permit(:size, :expired_date, :currency, :status, :unit_price, :dozen_price, :box_price, :dozen_units, :tags, :box_units, :supplier_id, images: [])
      # .merge(product_id: params[:product_id])
    end
  end
end