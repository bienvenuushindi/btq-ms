class Customer::ShippingAddress < ApplicationRecord
  belongs_to :individual_order
  has_one :address, -> { shipping_address }, as: :addressable,  class_name: 'Address'
  delegate :line1, :city, :phone_number1, to: :address, prefix: true
end
