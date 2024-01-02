class ProductDetailSerializer < Serializer
  attributes :size, :currency, :expired_date, :dozen_units, :box_units, :created_at, :updated_at, :image_urls, :status
  belongs_to :product
  has_many :price_details
  has_many :suppliers
  has_many :tags

  attribute :suppliers do |object|
    object.price_details
          .joins(supplier: [:country, :address])
          .select(
            'DISTINCT ON (suppliers.id) price_details.currency',
            'price_details.id',
            'price_details.price',
            'countries.name as country',
            'addresses.city',
            'addresses.line1 as address1',
            'addresses.line2 as address2',
            'addresses.phone_number1 as tel1',
            'addresses.phone_number2 as tel2',
            'price_details.quantity_type',
            'suppliers.id',
            'suppliers.shop_name',
            Arel.sql("TO_CHAR(price_details.updated_at, 'FMMonth FMDD, YYYY') AS last_update_at"),
            'price_details.updated_at'
          )
          .order('suppliers.id', 'price_details.updated_at DESC')
  end



  attribute :categories_suppliers do |object|
    object.product.categories.joins(:suppliers).select('suppliers.*')
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



  class << self
    def format_price(price)
      price.to_f.zero? ? '-' : price.to_s
    end
  end

end
