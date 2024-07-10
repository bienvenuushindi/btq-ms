class Category < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search, against: %i[name description], using: { tsearch: { prefix: true } }
  has_many :categorizations
  has_many :suppliers, through: :categorizations, source: :categorizable, source_type: 'Supplier'
  has_many :products, through: :categorizations, source: :categorizable, source_type: 'Product'
  has_many :product_details, through: :products
  belongs_to :parent_category, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_category_id'
  has_many :customer_preferences, :class_name => 'Customer::Preference'
  has_many :users, through: :customer_preferences
  has_one_attached :image
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  scope :parent_categories, -> { where(parent_category_id: nil) }
  # default_scope { where(active: true) }
  # Scope to load inactive records
  scope :inactive, -> { where(active: false) }
  # Scope to load all records
  scope :active, -> { where(active: true) }

  def active_products
    product_details.where(status: treu)
  end

  # Method to load inactive products
  def inactive_products
    product_details.where(status: false)
  end

  # Method to load all products
  def all_products
    product_details.unscoped
  end

  def image_url
    image.attached? ? image.blob.url : ['https://m.media-amazon.com/images/I/41EcYoIZhIL._AC_SY400_.jpg']
  end

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

  def customer_products(limit: 20)
    products.joins(:product_details).distinct.limit(limit)
  end

  def descendants
    children.map { |child| [child] + child.children }.flatten
  end

  def self.popular
    Category.order(preference_count: :desc)
  end
end
