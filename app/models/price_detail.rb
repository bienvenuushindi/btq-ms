class PriceDetail < ApplicationRecord
  belongs_to :supplier
  belongs_to :product_detail
  enum :quantity_type, { box: 0, dozen: 1, unit: 2 }
  validates :currency, presence: true
  before_validation :round_price_values

  def self.custom_upsert(prices, currency, supplier_id, product_detail_id)
    data = prices.map do |quantity_type, price|
      {
        price: price.to_d.round(2),
        quantity_type: quantity_type,
        currency: currency,
        supplier_id: supplier_id,
        product_detail_id: product_detail_id,
      }
    end

    PriceDetail.upsert_all(data, unique_by: %i[supplier_id product_detail_id quantity_type])
  end

  private

  def round_price_values
    self.price = price.to_d.round(2) if price.present?
  end
end
