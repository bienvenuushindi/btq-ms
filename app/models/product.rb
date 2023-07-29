class Product < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search, against: %i[name short_description], using: { tsearch: { prefix: true } }
  has_many :categories
  has_many :product_details
  has_and_belongs_to_many :tags
  belongs_to :user

  has_many_attached :images
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :short_description, presence: true
  validates :country_origin, presence: true

  def image_urls
    return   [ActionController::Base.helpers.image_url('no-img.png')] unless images.attached?
    images.map do |image|
      Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    end
  end
end
