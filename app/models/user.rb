class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

    record.errors.add attribute, (options[:message] || 'is not an email')
  end
end

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: self
  belongs_to :role
  has_many :products
  has_many :requisitions
  has_many :addresses, as: :addressable
  has_many :suppliers
  has_one_attached :image
  has_many :customer_preferences, :class_name => 'Customer::Preference'
  has_one :customer_price_preference, :class_name => 'Customer::PricePreference'
  has_many :categories, through: :customer_preferences
  has_many :customer_ratings, :class_name => 'Customer::Rating'

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, email: true
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  def image_url
    image.attached? ? image.blob.url  : [ActionController::Base.helpers.image_url('no-img.png')]
  end

  def fetch_data_based_on_preferences(limit: 20)
    if customer_preferences.present?
      fetch_data_based_on_user_preferences(limit)
    else
      fetch_data_based_on_popular_categories(limit)
    end
  end

  def fetch_data_based_categories(categories, limit: 20)
    fetch_product_details_grouped_by_category(categories, limit)
  end

  private

  def fetch_data_based_on_user_preferences(limit)
    preferred_categories = categories.flat_map { |category| [category] + category.descendants }.uniq
    fetch_product_details_grouped_by_category(preferred_categories, limit)
  end

  def fetch_data_based_on_popular_categories(limit)
    popular_categories = Category.order(preference_count: :desc)
    fetch_product_details_grouped_by_category(popular_categories, limit)
  end

  def fetch_product_details_grouped_by_category(categories, limit)
    categories.map do |category|
      category_ids = [category.id] + category.descendants.map(&:id)
      product_details = ProductDetail.fetch_by_category_ids(category_ids, limit)
      {
        name: category.name,
        count_products: category.count_products,
        description: category.description,
        image: category.image_url, # Assuming you have a method to get the image URL
        products: sort_product_details_by_popularity(product_details)
      }
    end
  end

  def sort_product_details_by_popularity(product_details)
    product_details.sort_by(&:popularity_score).reverse.map do |product_detail|
      product = product_detail.product
      product_detail.attributes.merge(
        product_name: product.name,
        image_url: product_detail.image_urls
      )
    end
  end
end
