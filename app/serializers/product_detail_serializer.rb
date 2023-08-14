class ProductDetailSerializer < Serializer
  attributes :size, :expired_date, :unit_price, :dozen_price, :box_price, :dozen_units, :box_units, :created_at, :updated_at, :image_urls
  belongs_to :product
  has_many :price_details
end
