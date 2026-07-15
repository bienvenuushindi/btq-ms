class SupplierProductDetail < ApplicationRecord
  belongs_to :supplier
  belongs_to :product_detail

  scope :supplier_active, -> { where(supplier_status: true) }
  scope :supplier_inactive, -> { where(supplier_status: false) }

  validates :supplier_id, uniqueness: { scope: :product_detail_id }
end
