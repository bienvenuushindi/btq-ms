class ProductSerializer
  include Rails.application.routes.url_helpers
  include JSONAPI::Serializer
  attributes :name, :short_description, :description, :active, :country_origin, :created_at, :updated_at, :image_urls

  has_many :product_detail
end
