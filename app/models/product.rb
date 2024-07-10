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
  validates :description, presence: true
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
    images.attached? ? images.map { |image| image.blob.url } : ['https://m.media-amazon.com/images/I/41mQKmbkVWL._AC_SY400_.jpg']
  end

end
