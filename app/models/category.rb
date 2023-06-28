class Category < ApplicationRecord
  has_many :suppliers
  has_many :products
  belongs_to :parent_category, class_name: 'Category', optional: true
  has_many :categories, foreign_key: :parent_category_id
end
