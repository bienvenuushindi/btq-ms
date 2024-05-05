# frozen_string_literal: true
module SupplierService
  module Options
    def self.index
      { fields: { supplier: [:id, :shop_name, :image_urls, :address] } }
    end

    def self.search
      { fields: { supplier: [:id, :shop_name, :image_urls, :address, :categories] } }
    end
  end
end