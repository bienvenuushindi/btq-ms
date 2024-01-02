class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true
  belongs_to :country
  validates :line1, presence: true
  validates :city, presence: true
  validates :phone_number1, presence: true
  scope :supplier_addresses, -> { where(addressable_type: 'Supplier') }
end
