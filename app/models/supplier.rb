class Supplier < ApplicationRecord
  has_many :addresses, as: :addressable
  has_many :countries, through: :addresses
  has_many :price_details
  has_many :product_details, through: :price_details
  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :categories
  validates :shop_name, presence:  true
end
