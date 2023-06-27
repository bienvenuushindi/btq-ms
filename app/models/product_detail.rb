class ProductDetail < ApplicationRecord
  belongs_to :product
  has_many :price_details
  has_many :suppliers, through: :price_details
end
