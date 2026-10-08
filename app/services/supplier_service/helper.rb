# frozen_string_literal: true
module SupplierService
  module Helper
    def self.index_options
      { fields: { supplier: [:id, :shop_name, :image_urls, :address, :user] } }
    end

    def self.search_options(product_detail_id = nil)
      {
        params: { product_detail_id: product_detail_id },
        fields: { supplier: [:id, :shop_name, :image_urls, :address, :categories, :registered_prices] }
      }
    end

    def self.supplier_params(params)
      params.require(:supplier).permit(:name, :email, :phone_number, :active, :shop_name, :address1, :address2, :city, :tel1, :country_name, :tel2, :country_id, :tags, :categories, images: [])
    end
  end
end
