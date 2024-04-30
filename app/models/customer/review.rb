class Customer::Review < ApplicationRecord
  belongs_to :user
  belongs_to :product_detail
end
