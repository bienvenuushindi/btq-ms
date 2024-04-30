class Customer::Cart < ApplicationRecord
  belongs_to :user

  validates :status, inclusion: { in: [true, false] }
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
