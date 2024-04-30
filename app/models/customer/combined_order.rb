class Customer::CombinedOrder < ApplicationRecord
  belongs_to :product_detail
  validates :status, presence: true, length: { maximum: 25 }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :quantity_type, presence: true, length: { maximum: 25 }
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
