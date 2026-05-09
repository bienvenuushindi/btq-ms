class Supplier < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search, against: %i[shop_name], using: { tsearch: { prefix: true } }
  has_one :address, -> { supplier_addresses }, as: :addressable
  has_one :country, through: :address, source: :country
  has_many :categorizations, as: :categorizable
  has_many :categories, through: :categorizations
  has_many :price_details
  has_many :product_details, through: :price_details
  has_many_attached :images
  belongs_to :user
  acts_as_taggable_on :tags
  validates :shop_name, presence: true

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

    [base_url.to_s.chomp('/'), '/images/supplier-placeholder.png'].join
  end

end
