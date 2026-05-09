class RequisitionSerializer < Serializer
  attributes :id, :total_price, :count_products, :count_products_bought, :price_currency, :archived, :date
  # attribute :product_items do |object|
  #   object.product_details.with_attached_images.joins(:product).select('product_details.*, products.name')
  # end

  attribute :total_price do |object|
    object[:total_price].to_d.round(2).to_f || 0
  end

  attribute :price_currency do |object|
    object[:price_currency] || '-'
  end

  attribute :archived do |object|
    object[:archived] || false
  end

  attribute :product_items do |object|
    # Fetch product details joined with products and product_details_requisitions
    # Select columns in the order that ensures product_details.id overrides other IDs
    # Ensure that the selection order of columns prioritizes product_details.id to override other IDs
    object.product_details
          .joins(:product)
          .select('products.name, product_details_requisitions.*, product_details.*')
          .distinct
          .map do |product_detail|
      # Convert ProductDetail to hash and exclude images
      product_detail_hash = product_detail.as_json
  
      # Build the final hash with additional attributes
      {
        **product_detail_hash, # Spread the attributes of product_detail
        image_urls: product_detail.image_urls, # Use the image_urls method from the ProductDetail model
        quantity_type: ProductDetailRequisition.reverse_quantity_types[product_detail.quantity_type],
        supplier_name: Supplier.find_by(id: product_detail.supplier_id)&.shop_name,
        price: product_detail.price.to_d.round(2).to_f,
        unit_price: product_detail.unit_price.to_d.round(2).to_f,
        dozen_price: product_detail.dozen_price.to_d.round(2).to_f,
        box_price: product_detail.box_price.to_d.round(2).to_f,
      }
    end
  end
  
end
