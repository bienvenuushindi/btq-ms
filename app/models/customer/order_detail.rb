class Customer::OrderDetail < ApplicationRecord
  belongs_to :individual_order, class_name: 'Customer::IndividualOrder', foreign_key: :customer_individual_order_id
  belongs_to :product_detail
  belongs_to :combined_order, class_name: 'Customer::CombinedOrder', foreign_key: :customer_combined_order_id

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :quantity_type, presence: true, length: { maximum: 25 }
end
