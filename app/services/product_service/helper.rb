# frozen_string_literal: true
module ProductService
  module Helper
    def self.search_options
      { fields: { product: %i[id name details] } }
    end

    def self.product_params(params)
    params.require(:product).permit(:name, :short_description, :description, :country_origin, :expirable, :approval_status, :rejection_reason, :catalog_scope, :active, :tags, :categories, images: [])
    end
  end
end
