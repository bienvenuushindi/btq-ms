class Api::V1::PriceDetailsController < ApplicationController
  def index
    prices = ProductDetail.visible_to(current_user).find(params[:product_detail_id]).price_details
    render json: { data: serializer.group_by_supplier(prices) }, status: :ok
  end

  def create
    permitted = price_detail_params
    supplier = Supplier.find(permitted[:supplier_id])
    if current_user.supplier? && !current_user.suppliers.where(id: supplier.id).exists?
      render json: { error: 'You can only update pricing for your own shop' }, status: :forbidden
      return
    end

    product_detail = ProductDetail.visible_to(current_user).find(permitted[:product_detail_id])
    result = SupplierProductDetail.transaction do
      selection = SupplierProductDetail.find_or_initialize_by(supplier: supplier, product_detail: product_detail)
      selection.supplier_status = ActiveModel::Type::Boolean.new.cast(permitted.fetch(:supplier_status, true))
      selection.expired_date = permitted[:expired_date].presence || selection.expired_date || product_detail.expired_date
      selection.save!
      PriceDetailService::Creator.call(permitted)
    end
    if result.respond_to?(:errors) && result.errors.any?
      render json: error_response(result), status: :unprocessable_entity
      return
    end

    render json: { status: 'success' }, status: :ok
  rescue ActiveRecord::RecordInvalid => e
    render json: error_response(e.record), status: :unprocessable_entity
  end

  def show
    render json: serialize_resource(visible_price_details.find(params[:id]), serializer), status: :ok
  end

  def destroy_for_supplier
    price_details = PriceDetail.where(
      product_detail_id: params[:product_detail_id],
      supplier_id: params[:supplier_id]
    )

    if price_details.exists?
      price_details.destroy_all
      render json: { status: 'success' }, status: :ok
    else
      render json: { error: 'Supplier pricing was not found for this product variant' }, status: :not_found
    end
  end

  private

  def serializer
    PriceDetailSerializer
  end

  def price_detail_params
    PriceDetailService::Helper.price_detail_params(params)
  end

  def visible_price_details
    PriceDetail.joins(:product_detail).merge(ProductDetail.visible_to(current_user))
  end
end
