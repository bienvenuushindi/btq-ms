class RequisitionSerializer
  include JSONAPI::Serializer
  attributes :total_price, :count_products, :count_products_bought, :price_currency, :archived, :date
  attribute :product_items do |object|
    object.product_details.with_attached_images.joins(:product).select('product_details.*, products.name')
  end

  attribute :total_price do |object|
    object[:total_price] || 0
  end

  attribute :price_currency do |object|
    object[:price_currency] || '-'
  end

  attribute :archived do |object|
    object[:archived] || false
  end

  attribute :product_items do |object|
    object.product_details.joins(:product).select('product_details.*, products.name,product_details_requisitions.*').distinct.map do |product_detail|
      product_detail_hash = product_detail.as_json # Convert ProductDetail to hash and exclude images
      {
        **product_detail_hash, # Spread the attributes of product_detail
        image_urls: product_detail.image_urls, # Use the image_urls method from the ProductDetail model
        quantity_type: ProductDetailRequisition.reverse_quantity_types[product_detail.quantity_type],
      }
    end
  end
end
