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
  after_destroy :downgrade_product_count
  before_destroy :decrement_total_price
  scope :bought, -> { where(found: true) }


  def self.reverse_quantity_types
    quantity_types.invert
  end

  def set_currency
    self.currency = requisition.price_currency
  end

  def update_product_count
    requisition.increment!(:count_products)
  end

  def update_product_found
    requisition.increment!(:count_products_bought, requisition.product_detail_requisitions.bought.count)
  end

  def update_total_price
    requisition.increment!(:total_price, (quantity * price))
  end

  def decrement_total_price
    requisition.decrement!(:total_price, (quantity * price))
  end

  def downgrade_product_count
    requisition.decrement!(:count_products)
  end
end
