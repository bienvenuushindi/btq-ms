# frozen_string_literal: true
module ProductService
  module Helper
    def self.search
      { fields: { product: %i[name details] } }
    end

    def self.product_params(params)
      params.require(:product).permit(:name, :short_description, :description, :active, :country_origin, :tags, :categories, images: [])
    end
  end
end
