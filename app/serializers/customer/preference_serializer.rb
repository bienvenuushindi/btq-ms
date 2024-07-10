class Customer::PreferenceSerializer < Serializer
  attributes :id
  attribute :category do |object|
    CategorySerializer.new(object.category, {fields: {category: %i[id name count_products description image_url]}}).serializable_hash[:data][:attributes]
  end
end
