class ProductDetail < ApplicationRecord
  belongs_to :product
  has_many :price_details
  has_many :suppliers, through: :price_details
  has_many :requisitions
  validates :size, presence: true
  validates :expired_date, presence: true
  validates :unit_price, presence: true
  validates :dozen_price, presence: true
  validates :box_price, presence: true
  validates :dozen_units, presence: true
  validates :box_units, presence: true
end
