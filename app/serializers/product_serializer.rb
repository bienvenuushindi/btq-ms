class ProductSerializer < Serializer
  has_many :product_details
  has_many :tags
  attributes :id, :name, :short_description, :description, :active, :approval_status, :rejection_reason, :catalog_scope, :country_origin, :updated_at, :image_urls
  attribute :details do |object, params|
    product_details_for(object, params)
      .select("product_details.id, product_details.size")
      .collect { |t| {id: t.id, name: "#{object.name} #{t.size}"} }
  end
  attribute :tags do |object|
    object.tags.map { |tag| tag['name'] }
  end
attribute :categories do |object|
  object.categories.select("categories.id, categories.name")
end
  attribute :created_at do |object|
    object.created_at.strftime("%B %-d, %Y")
  end

  attribute :supplier_status, if: proc { |_object, params| params&.[](:current_user)&.supplier? } do |object, params|
    current_user = params&.[](:current_user)

    supplier_ids = current_user.suppliers.select(:id)
    price_details = PriceDetail
      .joins(:product_detail)
      .where(supplier_id: supplier_ids, product_details: { product_id: object.id })

    if price_details.exists?
      price_details.supplier_active.exists? ? 'active' : 'inactive'
    elsif object.submitted_by_id == current_user.id
      'active'
    end
  end
  
  attribute :product_details do |object, params|
    options = { params: params }
    options[:fields] = { product: %i[name] }
    ProductDetailSerializer.new(product_details_for(object, params), options).serializable_hash[:data].map { |data| data[:attributes] }
  end

  class << self
    def product_details_for(object, params)
      current_user = params&.[](:current_user)
      details = object.product_details
      unless current_user&.supplier?
        return details.merge(ProductDetail.visible_to(current_user))
      end

      if params&.[](:include_available_details)
        available_detail_ids = details.merge(ProductDetail.visible_catalog).select(:id)
        selected_detail_ids = details.merge(ProductDetail.supplier_shop_for(current_user)).select(:id)

        return details.where(id: available_detail_ids).or(details.where(id: selected_detail_ids))
      end

      unless params&.[](:market_for_supplier)
        return details.merge(ProductDetail.supplier_shop_for(current_user))
      end

      selected_detail_ids = SupplierProductDetail
        .where(supplier_id: current_user.suppliers.select(:id))
        .select(:product_detail_id)

      details.merge(ProductDetail.visible_catalog).where.not(id: selected_detail_ids)
    end
  end
end
