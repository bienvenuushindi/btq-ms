class SupplierSerializer < Serializer
  attributes :id, :shop_name, :image_urls

  attribute :address1 do |object|
    object.address.line1
  end

  attribute :address2 do |object|
    object.address.line2
  end

  attribute :city do |object|
    object.address.city
  end

  attribute :country do |object|
    object.country.name
  end

  attribute :code do |object|
    object.country.code
  end

  attribute :tel1 do |object|
    object.address.phone_number1
  end

  attribute :tel2 do |object|
    object.address.phone_number2
  end

  attribute :tags do |object|
    object.tags.map { |tag| tag['name'] }
  end
end
