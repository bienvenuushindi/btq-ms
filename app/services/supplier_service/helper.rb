# frozen_string_literal: true
module SupplierService
  module Helper
    def self.index_options
      { fields: { supplier: [:id, :shop_name, :image_urls, :address] } }
    end

    def self.search_options
      { fields: { supplier: [:id, :shop_name, :image_urls, :address, :categories] } }
    end

    def self.supplier_params(params)
      params.require(:supplier).permit(:shop_name, :address1, :address2, :city, :tel1, :country_name, :tel2, :country_id, :tags, :categories, images: [])
    end
  end
end