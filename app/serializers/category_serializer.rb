class CategorySerializer < Serializer
  attributes :id, :name, :description, :active, :count_products, :parent_category_id, :image_url
  attribute :created_at do |object|
    object.created_at.strftime("%B %-d, %Y")
  end

  attribute :products do |object, params|
    current_user = params[:current_user]
    options = self.serializer_options(current_user)
    ProductDetailSerializer.new(self.filtered_product_details(object), options).serializable_hash[:data].map { |data| data[:attributes] }
  end

  attribute :children do |object, params|
    current_user = params[:current_user]
    fields = params[:fields] || self.fields_with_products
    options = { params: { current_user: current_user }, fields: { category: fields } }
    CategorySerializer.new(object.children, options).serializable_hash[:data].map { |data| data[:attributes] }
  end

  private

  class << self
    ALL_PRICE_KEYS = %w[unit_price dozen_price box_price].freeze

    def filtered_product_details(object)
      if object.children.present?
        # Filter out products that are also in children categories
        unique_products = object.product_details - object.children.map(&:product_details).flatten.uniq
      else
        unique_products = object.product_details
      end
      unique_products.sort_by(&:popularity_score).reverse
    end

    def serializer_options(current_user)
      current_keys = %i[id size currency expired_date unit_price dozen_price box_price dozen_units box_units image_urls status product_name].map(&:to_s)
      if current_user
        # Convert symbols to strings for easier manipulation
        excluded_price_keys = []
        preferences = current_user.price_preference_modified
        excluded_price_keys = ALL_PRICE_KEYS - preferences if preferences.present?

        # Determine which unit keys to exclude based on excluded price keys
        excluded_unit_keys = excluded_price_keys.map { |price_key| price_key.sub('_price', '_units') }

        # Remove the excluded price and unit keys
        (excluded_price_keys + excluded_unit_keys).each { |key| current_keys.delete(key) }
      end
      { fields: { product_detail: current_keys.map(&:to_sym) } }
    end

    def fields
      [:id, :name, :description, :active, :count_products, :children]
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
