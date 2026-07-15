class CategorySerializer < Serializer
  attributes :id, :name, :description, :active, :count_products, :parent_category_id, :image_url,
             :selected_variants_count, :market_variants_count
  attribute :created_at do |object|
    object.created_at.strftime("%B %-d, %Y")
  end

  attribute :products do |object, params|
    current_user = params&.[](:current_user)
    options = self.serializer_options(current_user)
    ProductDetailSerializer.new(self.filtered_product_details(object), options).serializable_hash[:data].map { |data| data[:attributes] }
  end

  attribute :children do |object, params|
    current_user = params&.[](:current_user)
    fields = params&.[](:fields) || self.fields_with_products
    options = { params: { current_user: current_user }, fields: { category: fields } }
    CategorySerializer.new(object.children, options).serializable_hash[:data].map { |data| data[:attributes] }
  end

  attribute :selected_variants_count do |object, params|
    current_user = params&.[](:current_user)
    category_detail_ids = self.category_detail_ids(object)

    if current_user&.supplier?
      ProductDetail.supplier_shop_for(current_user).where(id: category_detail_ids).count
    else
      ProductDetail.visible_to(current_user).where(id: category_detail_ids).count
    end
  end

  attribute :market_variants_count do |object, params|
    current_user = params&.[](:current_user)
    category_detail_ids = self.category_detail_ids(object)
    market_details = ProductDetail.visible_catalog.where(id: category_detail_ids)

    if current_user&.supplier?
      selected_detail_ids = SupplierProductDetail
        .where(supplier_id: current_user.suppliers.select(:id))
        .select(:product_detail_id)

      submitted_detail_ids = ProductDetail
        .where(submitted_by_id: current_user.id)
        .select(:id)

      market_details.where.not(id: selected_detail_ids).where.not(id: submitted_detail_ids).count
    else
      market_details.count
    end
  end

  private

  class << self
    def filtered_product_details(object)
      if object.children.present?
        # Filter out products that are also in children categories
        child_product_details = object.children.flat_map { |child| child.product_details.visible_catalog }.uniq
        unique_products = object.product_details.visible_catalog - child_product_details
      else
        unique_products = object.product_details.visible_catalog
      end
      unique_products.sort_by(&:popularity_score).reverse
    end

    def serializer_options(current_user)
      current_keys = %i[id size expired_date dozen_units box_units image_urls status approval_status product_name].map(&:to_s)
      { fields: { product_detail: current_keys.map(&:to_sym) } }
    end

    def category_detail_ids(object)
      object.product_details.select(:id)
    end

    def fields
      [:id, :name, :description, :active, :count_products, :selected_variants_count, :market_variants_count, :children]
    end

    def fields_with_products
      fields + [:products]
    end
  end

  # set_type :categories
  # has_many :children, record_type: :categories, serializer: self do |object|
  #   object[:children]
  # end

end
