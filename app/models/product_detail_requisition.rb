class ProductDetailRequisition < ApplicationRecord
  self.table_name = 'product_details_requisitions'
  belongs_to :requisition
  belongs_to :product_detail
  belongs_to :supplier, optional: true
  enum :quantity_type, { box: 0, dozen: 1, unit: 2 }
  enum :currency, { usd: 'usd', fc: 'fc', ugx: 'ugx', rw:'rw' }
  after_create :update_product_count
  after_save :update_total_price
  before_create :set_currency
  before_validation :set_default_status
  before_validation :round_price_values
  after_destroy :downgrade_product_count
  before_destroy :decrement_total_price
  scope :bought, -> { where(status: true) }


  def self.reverse_quantity_types
    quantity_types.invert
  end

  def set_currency
    self.currency = requisition.price_currency
  end

  def set_default_status
    self.status = false if status.nil?
  end

  def update_product_count
    requisition.increment!(:count_products)
  end

  def update_product_found
    requisition.increment!(:count_products_bought, requisition.product_detail_requisitions.bought.count)
  end

  def update_total_price
    q = quantity.to_i
    p = price.to_d
    requisition.update!(
      total_price: (requisition.total_price.to_d + (q * p)).round(2)
    )
    # requisition.increment!(:total_price, q * p)
  end

  def decrement_total_price
    q = quantity.to_i
    p = price.to_d

    requisition.update!(
      total_price: (requisition.total_price.to_d - (q * p)).round(2)
    )
    # requisition.decrement!(:total_price, q * p)
  end

  def downgrade_product_count
    q = quantity.to_i
    p = price.to_d

    requisition.update!(
      total_price: (requisition.total_price.to_d - (q * p)).round(2)
    )
    # requisition.increment!(:total_price, q * p)
  end

  def round_price_values
    self.price = price.to_d.round(2) if price.present?
  end
end
