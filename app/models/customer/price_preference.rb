class Customer::PricePreference < ApplicationRecord
  belongs_to :user
  validates :price_types, presence: true
  validates :user_id, uniqueness: true
  validate :price_types_must_not_be_empty

  private

  def price_types_must_not_be_empty
    if price_types.blank? || price_types.empty?
      errors.add(:price_types, "can't be blank")
    end
  end
end
