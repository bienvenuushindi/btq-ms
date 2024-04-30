class Customer::ShippingAddress < ApplicationRecord
  belongs_to :individual_order
  belongs_to :address, polymorphic: true
end
