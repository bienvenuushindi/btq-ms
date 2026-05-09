class SupplierSerializer < Serializer
  attributes :id, :shop_name, :image_urls

  attribute :address do |object|
    {
      address1: object.address&.line1,
      address2: object.address&.line2,
      city: object.address&.city,
      country: object.country&.name,
      code: object.country&.code,
      tel1: object.address&.phone_number1,
      tel2: object.address&.phone_number2
    }
  end
  
  attribute :categories do |object|
  object.categories.select("categories.id, categories.name")
  end

  attribute :tags do |object|
    object.tags.map { |tag| tag['name'] }
  end
end
