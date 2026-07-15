class Product < ApplicationRecord
  include AttachmentUrlHelper
  include PgSearch::Model
  pg_search_scope :search, against: %i[name short_description], using: { tsearch: { prefix: true } }
  has_many :categorizations, as: :categorizable
  has_many :categories, through: :categorizations
  has_many :product_details
  belongs_to :submitted_by, class_name: 'User', optional: true
  belongs_to :reviewed_by, class_name: 'User', optional: true
  acts_as_taggable_on :tags
  belongs_to :user
  has_many_attached :images
  enum :approval_status, { pending_review: 0, approved: 1, rejected: 2 }
  enum :catalog_scope, { public_catalog: 0, private_catalog: 1 }
  validates :name, presence: true, uniqueness: true
  validates :short_description, presence: true
  validates :country_origin, presence: true
  before_validation :sync_active_with_approval_status

  scope :inactive, -> { where(active: false) }
  scope :active, -> { where(active: true) }
  scope :visible_catalog, -> { public_catalog.approved.active }
  scope :public_reviewable, -> { public_catalog }
  scope :supplier_selected_by, lambda { |user|
    selected_product_ids = ProductDetail
      .joins(:supplier_product_details)
      .where(supplier_product_details: { supplier_id: user.suppliers.select(:id) })
      .select(:product_id)

    where(id: selected_product_ids)
  }
  scope :submitted_by_user, ->(user) { where(submitted_by_id: user.id) }
  scope :supplier_shop_for, lambda { |user|
    supplier_selected_by(user).or(submitted_by_user(user))
  }
  scope :market_for, lambda { |user|
    selected_detail_ids = ProductDetail
      .joins(:supplier_product_details)
      .where(supplier_product_details: { supplier_id: user.suppliers.select(:id) })
      .select(:id)
    market_product_ids = ProductDetail
      .visible_catalog
      .where.not(id: selected_detail_ids)
      .select(:product_id)

    visible_catalog.where(id: market_product_ids)
  }
  scope :visible_to, lambda { |user|
    if user&.admin?
      public_reviewable
    elsif user&.supplier?
      supplier_shop_for(user)
    elsif user
      visible_catalog.or(where(submitted_by_id: user.id))
    else
      visible_catalog
    end
  }

  def approve!(reviewer)
    update!(
      approval_status: :approved,
      active: true,
      reviewed_by: reviewer,
      reviewed_at: Time.current,
      rejection_reason: nil
    )
  end

  def reject!(reviewer, reason = nil)
    update!(
      approval_status: :rejected,
      active: false,
      reviewed_by: reviewer,
      reviewed_at: Time.current,
      rejection_reason: reason
    )
  end

  # New method to filter by active
  def self.count_active
    active.count
  end

  # Method to count inactive products
  def self.count_inactive
    inactive.count
  end

  def self.supplier_counts(user)
    supplier_ids = user.suppliers.select(:id)
    supplier_selections = SupplierProductDetail.where(supplier_id: supplier_ids)
    selected_detail_ids = supplier_selections.select(:product_detail_id)
    active_detail_ids = supplier_selections.supplier_active.select(:product_detail_id)
    inactive_detail_ids = supplier_selections.supplier_inactive.select(:product_detail_id)
    submitted_without_shop_selection = ProductDetail
      .where(submitted_by_id: user.id)
      .where.not(id: selected_detail_ids)

    active_count = ProductDetail.where(id: active_detail_ids).count + submitted_without_shop_selection.active.count
    inactive_count = ProductDetail.where(id: inactive_detail_ids).where.not(id: active_detail_ids).count + submitted_without_shop_selection.inactive.count
    market_total_count = ProductDetail.visible_catalog.count
    market_remaining_count = ProductDetail.visible_catalog.where.not(id: selected_detail_ids).count

    {
      active: active_count,
      inactive: inactive_count,
      total: active_count + inactive_count,
      market_total: market_total_count,
      market: market_remaining_count
    }
  end

  def self.by_status(status)
     where(active: status)
  end

  def image_urls
    attachment_urls_or_default(images, default_image_url)
  end

  private

  def sync_active_with_approval_status
    self.active = approved?
  end

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

end
