class PriceDetail < ApplicationRecord
  belongs_to :supplier
  belongs_to :product_detail
  enum :quantity_type, { box: 0, dozen: 1, unit: 2 }
  scope :supplier_active, -> { where(supplier_status: true) }
  scope :supplier_inactive, -> { where(supplier_status: false) }
  validates :currency, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :quantity_type, presence: true
  validates :supplier_id, uniqueness: { scope: %i[product_detail_id quantity_type] }
  validate :product_detail_is_approved
  before_validation :round_price_values

  def self.custom_upsert(prices, currency, supplier_id, product_detail_id, supplier_status = true)
    product_detail = ProductDetail.find(product_detail_id)
    supplier = Supplier.find(supplier_id)
    unless product_detail_available_for_supplier?(product_detail, supplier)
      invalid_price_detail = PriceDetail.new(product_detail: product_detail, supplier_id: supplier_id, currency: currency)
      invalid_price_detail.errors.add(:product_detail, 'must be approved before supplier prices can be added')
      raise ActiveRecord::RecordInvalid.new(invalid_price_detail)
    end

    SupplierProductDetail.upsert(
      {
        supplier_id: supplier_id,
        product_detail_id: product_detail_id,
        supplier_status: ActiveModel::Type::Boolean.new.cast(supplier_status),
        created_at: Time.current,
        updated_at: Time.current
      },
      unique_by: :index_supplier_product_details_on_supplier_and_detail
    )

    data = prices.filter_map do |quantity_type, price|
      next if price.blank? || price.to_d <= 0

      {
        price: price.to_d.round(2),
        quantity_type: quantity_type,
        currency: currency,
        supplier_id: supplier_id,
        product_detail_id: product_detail_id,
        supplier_status: supplier_status,
      }
    end

    if data.empty?
      invalid_price_detail = PriceDetail.new(product_detail: product_detail, supplier_id: supplier_id, currency: currency)
      invalid_price_detail.errors.add(:base, 'Select at least one pricing size and enter a price before saving the supplier')
      raise ActiveRecord::RecordInvalid.new(invalid_price_detail)
    end

    PriceDetail.upsert_all(data, unique_by: %i[supplier_id product_detail_id quantity_type])
  end

  private

  def round_price_values
    self.price = price.to_d.round(2) if price.present?
  end

  def product_detail_is_approved
    return if self.class.product_detail_available_for_supplier?(product_detail, supplier)

    errors.add(:product_detail, 'must be approved before supplier prices can be added')
  end

  def self.product_detail_available_for_supplier?(product_detail, supplier)
    return false unless product_detail && supplier
    return true if product_detail.approved?

    product_detail.submitted_by_id == supplier.user_id
  end
end
