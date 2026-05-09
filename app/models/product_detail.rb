class ProductDetail < ApplicationRecord
  MAX_SALES_COUNT = 200
  MAX_VIEWS = 1000
  RATINGS_WEIGHT = 0.3
  SALES_WEIGHT = 0.5
  VIEWS_WEIGHT = 0.2
  belongs_to :product, class_name: 'Product'
  has_many :price_details
  has_many :suppliers, through: :price_details
  has_many :categories, through: :product
  has_many :product_detail_requisitions
  has_many :requisitions, through: :product_detail_requisitions
  has_many_attached :images
  has_many :customer_ratings, :class_name => 'Customer::Rating'
  acts_as_taggable_on :tags
  before_validation :normalize_size
  before_validation :round_price_values
  validates :size, presence: true
  validates :size, uniqueness: {
    scope: :product_id,
    case_sensitive: false,
    message: 'has already been used for this product'
  }
  validates :expired_date, presence: true
  validates :unit_price, presence: true
  validates :currency, presence: true

  # default_scope { where(status: true) }
  # Scope to load inactive records
  scope :inactive, -> { where(status: false) }
  scope :active, -> { where(status: true) }
  # Scope to load all records
  # scope :all_records, -> { unscope(where: :status) }

  scope :details_with_product_name, -> { joins(:product).select('product_details.*, products.name as product_name') }
  scope :sc_expired_soon, -> { where('expired_date > ?', Date.current).where('expired_date <= ?', 2.month.from_now) }
  scope :sc_expired, -> { where('expired_date <= ?', Date.current) }

  before_save :calculate_popularity_score
  after_create :increment_category_counts
  after_update :update_category_counts
  after_destroy :update_category_counts_on_destroy

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

  def self.fetch_by_category_ids(category_ids, limit)
    joins(product: :categories)
      .where(categories: { id: category_ids })
      .distinct
      .limit(limit)
  end


  def image_urls
    images.attached? ? images.map { |image| image.blob.url } : [default_image_url]
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
  def calculate_popularity_score
    ratings_score = customer_ratings.average(:score) || 0
    # sales_count_score = normalize(sales_count, MAX_SALES_COUNT) * SALES_WEIGHT
    # views_score = normalize(views, MAX_VIEWS) * VIEWS_WEIGHT
    #
    # popularity_score = (ratings_score * RATINGS_WEIGHT) + sales_count_score + views_score
    # update_column(:popularity_score, popularity_score)


    sales_factor = [sales_count / MAX_SALES_COUNT.to_f, 1].min
    views_factor = [views / MAX_VIEWS.to_f, 1].min
    rating_factor = ratings_score * RATINGS_WEIGHT

    self.popularity_score = (sales_factor + views_factor + rating_factor) / 3.0
  end


  private

  def default_image_url
    base_url = ENV['APP_URL'].presence
    base_url ||= begin
      options = Rails.application.config.action_mailer.default_url_options || {}
      host = options[:host]
      port = options[:port]
      if host.present?
        protocol = options[:protocol].presence || 'http'
        [protocol, '://', host, (port.present? ? ":#{port}" : '')].join
      end
    end

    [base_url.to_s.chomp('/'), '/images/product-placeholder.png'].join
  end

  def normalize(value, max_value)
    [value.to_f / max_value, 1.0].min  # Ensure the normalized value is capped at 1.0
  end
  def increment_category_counts
    categories.each do |category|
      if status
        category.increment!(:count_products)
      else
        category.increment!(:inactive_count_products)
      end
    end
  end

  def update_category_counts
    categories.each do |category|
      if status_changed?
        if status
          category.increment!(:count_products)
          category.decrement!(:inactive_count_products)
        else
          category.decrement!(:count_products)
          category.increment!(:inactive_count_products)
        end
      end
    end
  end

  def update_category_counts_on_destroy
    categories.each do |category|
      if status
        category.decrement!(:count_products)
      else
        category.decrement!(:inactive_count_products)
      end
    end
  end

  def normalize_size
    self.size = size.to_s.strip.presence
  end

  def round_price_values
    self.unit_price = unit_price.to_d.round(2) if unit_price.present?
    self.dozen_price = dozen_price.to_d.round(2) if dozen_price.present?
    self.box_price = box_price.to_d.round(2) if box_price.present?
  end
end
