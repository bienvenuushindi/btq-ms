class Customer::IndividualOrder < ApplicationRecord
  belongs_to :user
  validates :total_amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :status, presence: true, length: { maximum: 255 }
  validates :delivery_date, presence: true
end
