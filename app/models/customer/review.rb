class Customer::Review < ApplicationRecord
  belongs_to :user
  belongs_to :product_detail

  validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :comment, presence: true, length: { maximum: 25 }
end
