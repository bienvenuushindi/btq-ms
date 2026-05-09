class Customer::Payment < ApplicationRecord
  belongs_to :individual_order, class_name: 'Customer::IndividualOrder', foreign_key: :customer_individual_order_id

  validates :amount_paid, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :method, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :status, presence: true, length: { maximum: 25 }
end
