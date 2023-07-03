class Product < ApplicationRecord
  has_many :categories
  has_many :product_details
  has_and_belongs_to_many :tags
  belongs_to :user

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :short_description, presence: true
  validates :country_origin, presence: true
  # validates :active, inclusion: [true, false]
end
