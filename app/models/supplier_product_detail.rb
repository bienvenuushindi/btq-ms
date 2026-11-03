class SupplierProductDetail < ApplicationRecord
  belongs_to :supplier
  belongs_to :product_detail

  scope :supplier_active, -> { where(supplier_status: true) }
  scope :supplier_inactive, -> { where(supplier_status: false) }

  before_validation :clear_expiration_for_non_expirable_product
  validates :supplier_id, uniqueness: { scope: :product_detail_id }
  validates :expired_date, presence: true, if: -> { product_detail&.product&.expirable? }

  private

  def clear_expiration_for_non_expirable_product
    self.expired_date = nil if product_detail&.product && !product_detail.product.expirable?
  end
end
