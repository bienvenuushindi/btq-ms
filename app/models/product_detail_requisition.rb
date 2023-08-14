class ProductDetailRequisition < ApplicationRecord
  self.table_name = 'product_details_requisitions'
  belongs_to :requisition
  belongs_to :product_detail
  belongs_to :supplier, optional: true

  # validates :quantity_type, numericality: { greater_than_or_equal_to: 0 }
  # validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  # validates :expired_date, presence: true
  # validates :price, presence: true
  # validates :currency, presence: true
  after_save :update_product_count
  after_destroy :downgrade_product_count


  private
  def update_product_count
    requisition.increment!(:count_products)
  end

  def downgrade_product_count
    requisition.decrement!(:count_products)
  end
end
