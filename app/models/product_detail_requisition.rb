class ProductDetailRequisition < ApplicationRecord
  self.table_name = 'product_details_requisitions'
  belongs_to :requisition
  belongs_to :product_detail
  belongs_to :supplier, optional: true
  belongs_to :buyer_supplier, class_name: 'Supplier', optional: true
  enum :quantity_type, { box: 0, dozen: 1, unit: 2 }
  enum :currency, { usd: 'usd', fc: 'fc', ugx: 'ugx', rw:'rw' }
  after_create :update_product_count
  after_save :update_total_price
  before_create :set_currency
  before_validation :set_default_status
  before_validation :round_price_values
  after_destroy :downgrade_product_count
  before_destroy :decrement_total_price
  PENDING_STATUS = 0
  PURCHASED_STATUS = 1

  scope :bought, -> { where(status: PURCHASED_STATUS) }


  def self.reverse_quantity_types
    quantity_types.invert
  end

  def set_currency
    self.currency = requisition.price_currency
  end

  def set_default_status
    self.status = PENDING_STATUS if status.nil?
  end

  def update_product_count
    requisition.increment!(:count_products)
  end

  def update_product_found
    requisition.increment!(:count_products_bought, requisition.product_detail_requisitions.bought.count)
  end

  def update_total_price
    requisition.recalculate_purchased_total_price!
  end

  def decrement_total_price
    true
  end

  def downgrade_product_count
    requisition.decrement!(:count_products)
    requisition.update!(
      count_products_bought: requisition.product_detail_requisitions.bought.count
    )
    requisition.recalculate_purchased_total_price!
  end

  def round_price_values
    self.price = price.to_d.round(2) if price.present?
  end
end
