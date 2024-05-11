# frozen_string_literal: true
module CategoryService
  module Options
    def self.search
      { fields: { product: %i[name details] } }
    end
  end
  module Params
    def self.product_params(params)
      params.require(:category).permit(:name, :description, :active, :parent_category_id)
    end
  end

end
