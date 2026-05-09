class Customer::CartItem < ApplicationRecord
  belongs_to :cart, class_name: 'Customer::Cart', foreign_key: :customer_cart_id
  belongs_to :product_detail
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :quantity_type, presence: true, length: { maximum: 25 }
end
