class Product < ApplicationRecord
  has_many :categories
  has_many :product_details
  has_many :product_requisitions
  has_and_belongs_to_many :tags
  has_many :requisitions, through: :product_requisitions
  belongs_to :user
end
