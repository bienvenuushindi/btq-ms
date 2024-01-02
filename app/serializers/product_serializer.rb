class ProductSerializer < Serializer
  has_many :product_details
  has_many :tags
  attributes :name, :short_description, :description, :active, :country_origin, :updated_at, :image_urls
  attribute :details do |object|
    object.product_details.select("id, (size || '- $' || unit_price) as size_price").collect { |t| {id: t.id, name: "#{object.name} #{t.size_price}"} }
  end
  attribute :tags do |object|
    object.tags.map { |tag| tag['name'] }
  end
  attribute :categories do |object|
    object.categories.select("name")
 end
  attribute :created_at do |object|
    object.created_at.strftime("%B %-d, %Y")
  end
end
