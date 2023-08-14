class ProductDetail < ApplicationRecord
  belongs_to :product
  has_many :price_details
  has_many :suppliers, through: :price_details
  has_many :product_detail_requisitions
  has_many :requisitions, through: :product_detail_requisitions
  has_many_attached :images
  validates :size, presence: true
  validates :expired_date, presence: true
  validates :unit_price, presence: true
  validates :dozen_price, presence: true
  validates :box_price, presence: true
  validates :dozen_units, presence: true
  validates :box_units, presence: true

  def image_urls
    return   [ActionController::Base.helpers.image_url('no-img.png')] unless images.attached?
    images.map do |image|
      Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    end
  end
end
