class ProductDetailSerializer
  include JSONAPI::Serializer
  attributes :size, :expired_date, :unit_price, :dozen_price, :box_price, :dozen_units, :box_units, :created_at, :updated_at

  belongs_to :product
  has_many :price_detail
end
