class ProductDetailRequisition < ApplicationRecord
  belongs_to :requisition
  belongs_to :product

  validates :quantity_type, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :expired_date, presence: true
  validates :price, presence: true
  validates :currency, presence: true
end
