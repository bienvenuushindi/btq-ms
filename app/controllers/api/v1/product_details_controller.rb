class Api::V1::ProductDetailsController < ApplicationController
  before_action :set_product_detail, only: %i[show update]
  before_action :set_product, only: %i[index]

  def index
    @product_details = ProductDetailService::Retriever.call(product_detail_scope, params)
    render_collection(paginate(@product_details), serializer, ProductDetailService::Helper.index_options.deep_merge(serializer_options))
  end

  def expiring_soon
    render_collection(
      paginate(ProductDetailService::Retriever.expired_soon(params, shelf_life_scope)),
      serializer,
      ProductDetailService::Helper.expiring_soon_options.deep_merge(serializer_options)
    )
  end

  def expired
    render_collection(
      paginate(ProductDetailService::Retriever.expired(params, shelf_life_scope)),
      serializer,
      ProductDetailService::Helper.expiring_soon_options.deep_merge(serializer_options)
    )
  end

  def shelf_life_stats
    scope = shelf_life_scope
    render json: {
      data: {
        expiring_soon: scope.sc_expired_soon.count,
        expired: scope.sc_expired.count
      }
    }, status: :ok
  end

  def create
    @product_detail = ProductDetailService::Creator.call(product_detail_params.merge(product_id: params[:product_id]), current_user)
    render_serialized_resource(@product_detail, serializer, :created, serializer_options)
  end

  def suppliers
    product_detail = ProductDetail.visible_to(current_user).find(params[:id])

    render json: {
      data: {
        suppliers: supplier_purchase_history(product_detail)
      }
    }, status: :ok
  end

  def show
    render json: serialize_resource(
      @product_detail,
      serializer,
      serializer_options
    ), status: :ok
  end

  def update
    if ProductDetailService::Updater.call(@product_detail, product_detail_params, current_user)
      render json: serialize_resource(@product_detail, serializer, serializer_options), status: :ok
    else
      render json: error_response(@product_detail), status: :unprocessable_entity
    end
  end

  private

  def serializer
    ProductDetailSerializer
  end

  def serializer_options
    { params: { current_user: current_user } }
  end

  def set_product
    @product = Product.find(params[:product_id])
  end

  def product_detail_scope
    scope = current_user.supplier? ? ProductDetail.supplier_shop_for(current_user) : ProductDetail.visible_to(current_user)
    @product.product_details.merge(scope)
  end

  def shelf_life_scope
    current_user.supplier? ? ProductDetail.supplier_shop_for(current_user) : ProductDetail.visible_to(current_user)
  end

  def set_product_detail
    @product_detail = ProductDetail.visible_to(current_user).find(params[:id])
  end

  def product_detail_params
    ProductDetailService::Helper.product_detail_params(params)
  end

  def supplier_purchase_history(product_detail)
    return product_detail.suppliers_prices.map { |supplier| supplier_history_payload(supplier) } unless current_user&.supplier?

    history_items = ProductDetailRequisition
      .bought
      .where(product_detail_id: product_detail.id, buyer_supplier_id: current_user.suppliers.select(:id))
      .where.not(supplier_id: nil)
      .includes(supplier: [:address, :country])
      .order(updated_at: :desc)

    history_items
      .each_with_object({}) do |item, suppliers|
        suppliers[item.supplier_id] ||= requisition_supplier_history_payload(item)
      end
      .values
  end

  def supplier_history_payload(supplier)
    {
      id: supplier.id,
      currency: supplier.currency,
      price: supplier.price,
      quantity_type: supplier.quantity_type,
      shop_name: supplier.shop_name,
      last_update_at: supplier.last_update_at,
      address: {
        city: supplier.city,
        address1: supplier.address1,
        address2: supplier.address2,
        country: supplier.country,
        tel1: supplier.tel1,
        tel2: supplier.tel2
      }
    }
  end

  def requisition_supplier_history_payload(item)
    supplier = item.supplier
    address = supplier&.address

    {
      id: supplier&.id,
      currency: item.currency,
      price: item.price,
      quantity_type: item.quantity_type,
      shop_name: supplier&.shop_name,
      last_update_at: item.updated_at&.strftime('%B %-d, %Y'),
      address: {
        city: address&.city,
        address1: address&.line1,
        address2: address&.line2,
        country: supplier&.country&.name,
        tel1: address&.phone_number1,
        tel2: address&.phone_number2
      }
    }
  end

end
