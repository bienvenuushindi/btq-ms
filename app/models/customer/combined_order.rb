class Customer::CombinedOrder < ApplicationRecord
  belongs_to :product_detail
end
