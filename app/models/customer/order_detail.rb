class Customer::OrderDetail < ApplicationRecord
  belongs_to :individual_order
  belongs_to :product_detail
  belongs_to :combined_order

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :quantity_type, presence: true, length: { maximum: 25 }
end
