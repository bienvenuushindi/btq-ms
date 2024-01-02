class Category < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search, against: %i[name description], using: { tsearch: { prefix: true } }
  has_many :categorizations
  has_many :suppliers, through: :categorizations
  has_many :products, through: :categorizations
  belongs_to :parent_category, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_category_id'

  # Add these attributes for JSON API serialization
  attribute :name
  attribute :children

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  def self.tree_structure(parent_id = nil)
    categories = where(parent_category_id: parent_id)

    categories.map do |category|
      {
        id: category.id, # Include a unique identifier for each category
        name: category.name,
        children: tree_structure(category.id)
      }
    end
  end
end
