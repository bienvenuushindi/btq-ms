class ProductSerializer < Serializer
  has_many :product_details
  attributes :name, :short_description, :description, :active, :country_origin, :created_at, :updated_at, :image_urls
  attribute :details do |object|
    object.product_details.select("id, (size || '- $' || unit_price) as size_price").collect { |t| {id: t.id, name: "#{object.name} #{t.size_price}"} }
  end
end
