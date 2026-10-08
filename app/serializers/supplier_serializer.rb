class SupplierSerializer < Serializer
  attributes :id, :shop_name, :image_urls

  attribute :temporary_password, if: proc { |_object, params|
    params&.[](:include_temporary_password)
  } do |object|
    object.temporary_password
  end

  attribute :user do |object|
    {
      id: object.user_id,
      name: object.user&.name,
      email: object.user&.email,
      phone_number: object.user&.phone_number,
      role: object.user&.role&.name,
      active: object.user&.active?
    }
  end

  attribute :registered_prices, if: proc { |_object, params|
    params&.[](:product_detail_id).present?
  } do |object, params|
    object.price_details
          .supplier_active
          .where(product_detail_id: params[:product_detail_id])
          .order(:quantity_type)
          .map do |price_detail|
      {
        price: price_detail.price,
        currency: price_detail.currency,
        quantity_type: price_detail.quantity_type
      }
    end
  end

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
