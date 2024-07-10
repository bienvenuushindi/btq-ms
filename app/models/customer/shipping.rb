class Customer::Shipping < ApplicationRecord
  belongs_to :individual_order
  belongs_to :address, -> { shipping_address },  class_name: 'Address'
  delegate :line1, :city, :phone_number1, to: :address, prefix: false
end
