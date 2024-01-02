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

  # New method to filter by status
  def self.by_status(status)
    where(active: status)
  end

  def self.count_by_status(status)
    self.by_status(status).count
  end

  def image_urls
    return   [ActionController::Base.helpers.image_url('no-img.png')] unless images.attached?
    images.map do |image|
      Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    end
  end
end
