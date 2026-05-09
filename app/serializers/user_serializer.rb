class UserSerializer < Serializer
  attributes :id, :email, :name, :phone_number, :image_url, :default_currency

  attribute :image_urls do |object|
    Array(object.image_url)
  end

  attribute :address do |object|
    address = object.addresses.first

    {
      address1: address&.line1,
      address2: address&.line2,
      city: address&.city,
      country: address&.country&.name,
      code: address&.country&.code,
      tel1: address&.phone_number1 || object.phone_number,
      tel2: address&.phone_number2
    }
  end
end
