# frozen_string_literal: true
module PriceDetailService
  module Options
    def self.search
    end
  end
  module Params
    def self.price_detail_params(params)
      params.require(:price_detail).permit(:supplier_id, :currency, :product_detail_id, prices: [:box, :dozen, :unit])
    end
  end

end
