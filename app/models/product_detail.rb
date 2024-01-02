class ProductDetail < ApplicationRecord
  belongs_to :product
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
    sc_expired_soon.limit(limit)
  end

  def self.last_expired(limit=5)
    sc_expired.limit(limit)
  end
  def self.count_expired
    sc_expired.count
  end

  def self.count_expired_soon
    sc_expired_soon.count
  end
  def image_urls
    return   [ActionController::Base.helpers.image_url('no-img.png')] unless images.attached?
    images.map do |image|
      Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    end
  end

  def categories_suppliers
    product.categories.joins(:suppliers).select('suppliers.*')
  end

end
