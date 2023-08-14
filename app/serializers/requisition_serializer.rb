class RequisitionSerializer
  include JSONAPI::Serializer
  attributes :total_price, :count_products, :count_products_bought, :price_currency, :archived, :date
  attribute :product_items do |object|
    object.product_details.with_attached_images.joins(:product).select('product_details.*, products.name')
  end

  attribute :product_items do |object|
    object.product_details.with_attached_images.joins(:product).select('product_details.*, products.name').map do |product_detail|
      product_detail_hash = product_detail.as_json # Convert ProductDetail to hash and exclude images
      {
        **product_detail_hash, # Spread the attributes of product_detail
        image_urls: product_detail.image_urls, # Use the image_urls method from the ProductDetail model
      }
    end
  end
end
# attribute :details  do |object|
#   options={}
#   options[:include] =['product']
#   options[:fields] = { product: [:name, :details] }
#   ProductDetailSerializer.new(object.product_details,options)
# end