class RequisitionSerializer < Serializer
  attributes :id, :price_currency, :archived, :date
  # attribute :product_items do |object|
  #   object.product_details.with_attached_images.joins(:product).select('product_details.*, products.name')
  # end

  attribute :total_price do |object, params|
    RequisitionSerializer.scoped_requisition_items(object, params&.dig(:current_user))
                         .bought
                         .sum('COALESCE(quantity, 0) * COALESCE(price, 0)')
                         .to_d
                         .round(2)
                         .to_f
  end

  attribute :count_products do |object, params|
    RequisitionSerializer.scoped_requisition_items(object, params&.dig(:current_user)).count
  end

  attribute :count_products_bought do |object, params|
    RequisitionSerializer.scoped_requisition_items(object, params&.dig(:current_user)).bought.count
  end

  attribute :price_currency do |object|
    object[:price_currency] || '-'
  end

  attribute :archived do |object|
    object[:archived] || false
  end

  attribute :product_items do |object, params|
    current_user = params&.dig(:current_user)
    requisition_items = RequisitionSerializer.scoped_requisition_items(object, current_user)

    requisition_items
          .joins(product_detail: :product)
          .includes(:supplier, :buyer_supplier, product_detail: :product)
          .order(
            'product_details_requisitions.status ASC',
            Arel.sql('LOWER(products.name) ASC'),
            'product_details_requisitions.id ASC'
          )
          .map do |requisition_item|
      product_detail = requisition_item.product_detail
      product_detail_hash = product_detail.as_json

      {
        **product_detail_hash,
        name: product_detail.product&.name,
        image_urls: product_detail.image_urls,
        product_detail_id: product_detail.id,
        product_expired_date: product_detail.expired_date,
        requisition_item_id: requisition_item.id,
        requisition_id: requisition_item.requisition_id,
        status: requisition_item.status || ProductDetailRequisition::PENDING_STATUS,
        quantity: requisition_item.quantity,
        quantity_type: ProductDetailRequisition.reverse_quantity_types[requisition_item.quantity_type],
        buyer_supplier_id: requisition_item.buyer_supplier_id,
        buyer_supplier_name: requisition_item.buyer_supplier&.shop_name,
        supplier_id: requisition_item.supplier_id,
        supplier_name: requisition_item.supplier&.shop_name,
        expired_date: requisition_item.expired_date,
        currency: requisition_item.currency,
        note: requisition_item.note,
        price: requisition_item.price.to_d.round(2).to_f,
      }
    end
  end

  def self.scoped_requisition_items(requisition, current_user)
    requisition_items = requisition.product_detail_requisitions
    return requisition_items unless current_user&.supplier? && !current_user&.admin?

    supplier_ids = current_user.suppliers.select(:id)
    requisition_items
      .where(buyer_supplier_id: supplier_ids)
      .or(requisition_items.where(supplier_id: supplier_ids))
  end
  
end
