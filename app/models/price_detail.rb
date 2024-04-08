class PriceDetail < ApplicationRecord
  belongs_to :supplier
  belongs_to :product_detail
  enum :quantity_type, { box: 0, dozen: 1, unit: 2 }
  validates :currency, presence: true

  def self.custom_upsert(prices, currency, supplier_id, product_detail_id)
    data = prices.map do |quantity_type, price|
      {
        price: price,
        quantity_type: quantity_type,
        currency: currency,
        supplier_id: supplier_id,
        product_detail_id: product_detail_id,
      }
    end

    PriceDetail.upsert_all(data, unique_by: %i[supplier_id product_detail_id quantity_type])
  end
end
