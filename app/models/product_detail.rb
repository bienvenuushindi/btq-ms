class ProductDetail < ApplicationRecord
  belongs_to :product, class_name: 'Product'
  has_many :price_details
  has_many :suppliers, through: :price_details
  has_many :product_detail_requisitions
  has_many :requisitions, through: :product_detail_requisitions
  has_many_attached :images
  acts_as_taggable_on :tags
  validates :size, presence: true
  validates :expired_date, presence: true
  validates :unit_price, presence: true
  validates :currency, presence: true


  scope :details_with_product_name, -> { joins(:product).select('product_details.*, products.name as product_name') }
  scope :sc_expired_soon, -> { where('expired_date > ?', Date.current).where('expired_date <= ?', 2.month.from_now) }
  scope :sc_expired, -> { where('expired_date <= ?', Date.current) }

  def self.count(status=nil)

  end
  def self.expired_soon
    details_with_product_name.sc_expired_soon
  end
  def self.expired
    details_with_product_name.sc_expired
  end

  def self.last_soon_expired(limit=5)
    details_with_product_name.sc_expired_soon.limit(limit)
  end

  def self.last_expired(limit=5)
    details_with_product_name.sc_expired.limit(limit)
  end
  def self.count_expired
    sc_expired.count
  end

  def self.count_expired_soon
    sc_expired_soon.count
  end

  def image_urls
    images.attached? ? images.map { |image| image.blob.url } :  [ActionController::Base.helpers.image_url('no-img.png')]
  end

  def categories_suppliers
    Product.joins(categories: [:suppliers]).where(id: self.product_id).select('suppliers.*')
  end

  def suppliers_prices
    price_details.joins(supplier: [:country, :address]).select(
            'DISTINCT ON (suppliers.id) price_details.currency',
            'price_details.id',
            'price_details.price',
            'price_details.quantity_type',
            'suppliers.shop_name',
            'countries.name as country',
            Arel.sql("TO_CHAR(price_details.updated_at, 'FMMonth FMDD, YYYY') AS last_update_at"),
            'addresses.city',
            'addresses.line1 as address1',
            'addresses.line2 as address2',
            'addresses.phone_number1 as tel1',
            'addresses.phone_number2 as tel2'
          )
          .order('suppliers.id', 'price_details.updated_at DESC')
  end
end
