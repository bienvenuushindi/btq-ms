class Customer::PreferenceSerializer < Serializer
  attributes :id
  belongs_to :category, serializer: CategorySerializer

  # You can also add a custom method to include additional data if needed
  attribute :category do |object|
    CategorySerializer.new(object.category, {fields: {category: %i[id name count_products description]}}).serializable_hash[:data][:attributes]
  end
end