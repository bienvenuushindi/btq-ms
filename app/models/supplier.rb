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
    return [ActionController::Base.helpers.image_url('no-img.png')] unless images.attached?
    images.map do |image|
      Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    end
  end


end
