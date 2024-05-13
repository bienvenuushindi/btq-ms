# frozen_string_literal: true
module ProductDetailService
  module Options
    def self.search
      { fields: { product_detail: %i[id size currency expired_date dozen_units box_units created_at image_urls status product_name] } }
    end
  end
  module Params
    def self.product_detail_params(params)
      params.require(:product_detail).permit(:size, :expired_date, :currency, :status, :unit_price, :dozen_price, :box_price, :dozen_units, :tags, :box_units, :supplier_id, images: [])
            # .merge(product_id: params[:product_id])
    end
  end
end