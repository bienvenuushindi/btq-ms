class Customer::IndividualOrderDetail < ApplicationRecord
  belongs_to :individual_order
  belongs_to :product_detail
  belongs_to :combined_order
end
