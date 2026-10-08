class ProductDetailSerializer < Serializer
  attributes :id, :product_id, :size, :expired_date, :dozen_units, :box_units, :created_at, :image_urls, :status, :approval_status, :rejection_reason
  belongs_to :product
  has_many :price_details
  has_many :suppliers
  has_many :tags

  attribute :suppliers do |object|
    price_details = object.suppliers_prices
    price_details.map do |pd|
      {
        id: pd.id,
        currency: pd.currency,
        price: pd.price,
        quantity_type: pd.quantity_type,
        shop_name: pd.shop_name,
        last_update_at: pd.last_update_at,
        address: {
          city: pd.city,
          address1: pd.address1,
          address2: pd.address2,
          country: pd.country,
          tel1: pd.tel1,
          tel2: pd.tel2
        }
      }
    end
  end

  attribute :supplier_status, if: proc { |_object, params| params&.[](:current_user)&.supplier? } do |object, params|
    selection = ProductDetailSerializer.supplier_selection(object, params&.[](:current_user))
    selection&.supplier_status
  end

  attribute :expired_date do |object, params|
    ProductDetailSerializer.expiration_for(object, params&.[](:current_user), params&.[](:supplier_shop_id))
  end

  attribute :shop_prices, if: proc { |_object, params| params&.[](:current_user)&.supplier? || params&.[](:supplier_shop_id).present? } do |object, params|
    supplier_ids = if params&.[](:supplier_shop_id).present?
                     [params[:supplier_shop_id]]
                   else
                     params[:current_user].suppliers.select(:id)
                   end
    object.price_details
      .supplier_active
      .where(supplier_id: supplier_ids)
      .map do |price_detail|
        {
          id: price_detail.id,
          price: price_detail.price,
          quantity_type: price_detail.quantity_type,
          currency: price_detail.currency,
          supplier_status: price_detail.supplier_status
        }
      end
  end

  attribute :can_delete do |object, params|
    current_user = params&.[](:current_user)
    allowed = current_user.present? && (current_user.admin? || object.submitted_by_id == current_user.id)
    allowed && !object.selected_by_any_shop?
  end

  attribute :categories_suppliers do |object|
    object.categories_suppliers
  end

  attribute :tags do |object|
    object.tags.map(&:name)
  end

  %i[dozen_units box_units].each do |pack_attribute|
    attribute pack_attribute do |object|
      object.public_send(pack_attribute)
    end
  end

  attribute :product_name do |object|
    object.product.name if object.product
  end

  attribute :product_name do |object|
    object.product.name if object.product
  end

  attribute :expired_status do |object, params|
    effective_expiration = ProductDetailSerializer.expiration_for(object, params&.[](:current_user), params&.[](:supplier_shop_id))
    if effective_expiration.nil?
      "unknown"
    else
      today = Date.today
      expired_date = effective_expiration.to_date

      if expired_date < today
        "expired"
      elsif expired_date <= today + 2.months
        "soon"
      else
        "good"
      end
    end
  end

  class << self
    def supplier_selection(object, current_user)
      return unless current_user&.supplier?

      object.supplier_product_details.find_by(supplier_id: current_user.suppliers.select(:id))
    end

    def expiration_for(object, current_user, supplier_shop_id = nil)
      selection = if supplier_shop_id.present?
                    object.supplier_product_details.find_by(supplier_id: supplier_shop_id)
                  else
                    supplier_selection(object, current_user)
                  end
      selection&.expired_date || object.expired_date
    end
  end
end
