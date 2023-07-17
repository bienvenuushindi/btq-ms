class ProductSerializer
  include JSONAPI::Serializer
  attributes :name, :short_description, :description, :active, :country_origin, :created_at, :updated_at

  has_many :product_detail
end
