class Product < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search, against: %i[name short_description], using: { tsearch: { prefix: true } }
  has_many :categorizations, as: :categorizable
  has_many :categories, through: :categorizations
  has_many :product_details
  acts_as_taggable_on :tags
  belongs_to :user
  has_many_attached :images
  validates :name, presence: true, uniqueness: true
  validates :short_description, presence: true
  validates :country_origin, presence: true

  scope :inactive, -> { where(active: false) }
  scope :active, -> { where(active: true) }

  # New method to filter by active
  def self.count_active
    active.count
  end

  # Method to count inactive products
  def self.count_inactive
    inactive.count
  end

  def self.by_status(status)
     where(active: status)
  end

  def image_urls
    images.attached? ? images.map { |image| image.blob.url } : [default_image_url]
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

end
