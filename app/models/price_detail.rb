class PriceDetail < ApplicationRecord
  belongs_to :supplier
  belongs_to :product_detail
end
