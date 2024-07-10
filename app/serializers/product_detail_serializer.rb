class ProductDetailSerializer < Serializer
  attributes :id, :size, :currency, :expired_date, :dozen_units, :box_units, :created_at, :image_urls, :status
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

  attribute :categories_suppliers do |object|
    object.categories_suppliers
  end

  attribute :tags do |object|
    object.tags.map(&:name)
  end



  %i[unit_price dozen_price box_price dozen_units box_units].each do |price_attribute|
    attribute price_attribute do |object|
      self.format_price(object.public_send(price_attribute))
    end
  end

  attribute :product_name do |object|
    object.product.name if object.product
  end

  attribute :product_name do |object|
    object.product.name if object.product
  end



  class << self
    def format_price(price)
      price.to_f.zero? ? '-' : price.to_s
    end
  end

end
