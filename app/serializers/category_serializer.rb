class CategorySerializer
  include JSONAPI::Serializer
  attributes  :name, :description, :active, :count_products, :parent_category_id, :children
  attribute :created_at do |object|
    object.created_at.strftime("%B %-d, %Y")
  end
  # set_type :categories
  # has_many :children, record_type: :categories, serializer: self do |object|
  #   object[:children]
  # end
end
