class ProductDetail < ApplicationRecord
  include AttachmentUrlHelper
  MAX_SALES_COUNT = 200
  MAX_VIEWS = 1000
  RATINGS_WEIGHT = 0.3
  SALES_WEIGHT = 0.5
  VIEWS_WEIGHT = 0.2
  belongs_to :product, class_name: 'Product'
  belongs_to :submitted_by, class_name: 'User', optional: true
  belongs_to :reviewed_by, class_name: 'User', optional: true
  has_many :price_details
  has_many :supplier_product_details
  has_many :suppliers, through: :price_details
  has_many :categories, through: :product
  has_many :product_detail_requisitions
  has_many :requisitions, through: :product_detail_requisitions
  has_many_attached :images
  has_many :customer_ratings, :class_name => 'Customer::Rating'
  acts_as_taggable_on :tags
  enum :approval_status, { pending_review: 0, approved: 1, rejected: 2 }
  before_validation :normalize_size
  before_validation :sync_status_with_approval_status
  validates :size, presence: true
  validates :size, uniqueness: {
    scope: :product_id,
    case_sensitive: false,
    message: 'has already been used for this product'
  }
  validates :expired_date, presence: true

  # default_scope { where(status: true) }
  # Scope to load inactive records
  scope :inactive, -> { where(status: false) }
  scope :active, -> { where(status: true) }
  scope :visible_catalog, -> { approved.active.joins(:product).merge(Product.visible_catalog) }
  scope :supplier_shop_for, lambda { |user|
    supplier_ids = user.suppliers.select(:id)
    selected_product_detail_ids = SupplierProductDetail
      .where(supplier_id: supplier_ids)
      .select(:product_detail_id)

    where(id: selected_product_detail_ids)
      .or(where(submitted_by_id: user.id))
  }
  scope :visible_to, lambda { |user|
    if user&.admin?
      joins(:product).merge(Product.public_reviewable)
    elsif user&.supplier?
      supplier_ids = user.suppliers.select(:id)
      selected_product_detail_ids = PriceDetail
        .where(supplier_id: supplier_ids)
        .select(:product_detail_id)
      shop_product_detail_ids = SupplierProductDetail
        .where(supplier_id: supplier_ids)
        .select(:product_detail_id)

      where(id: visible_catalog.select(:id))
        .or(where(submitted_by_id: user.id))
        .or(where(id: selected_product_detail_ids))
        .or(where(id: shop_product_detail_ids))
    elsif user
      visible_catalog.or(where(submitted_by_id: user.id))
    else
      visible_catalog
    end
  }
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

  def approve!(reviewer)
    update!(
      approval_status: :approved,
      status: true,
      reviewed_by: reviewer,
      reviewed_at: Time.current,
      rejection_reason: nil
    )
  end

  def reject!(reviewer, reason = nil)
    update!(
      approval_status: :rejected,
      status: false,
      reviewed_by: reviewer,
      reviewed_at: Time.current,
      rejection_reason: reason
    )
  end

  def self.fetch_by_category_ids(category_ids, limit)
    joins(product: :categories)
      .where(categories: { id: category_ids })
      .distinct
      .limit(limit)
  end


  def image_urls
    attachment_urls_or_default(images, default_image_url)
  end

  def categories_suppliers
    Product.joins(categories: [:suppliers]).where(id: self.product_id).select('suppliers.*')
  end

  def suppliers_prices
    price_details.joins(supplier: [:country, :address]).select(
            'DISTINCT ON (suppliers.id) price_details.currency',
            'suppliers.id',
            'price_details.id as price_detail_id',
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

  def sync_status_with_approval_status
    self.status = approved?
  end

end
