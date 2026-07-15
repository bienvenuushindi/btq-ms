class Api::V1::PriceDetailsController < ApplicationController
  def index
    prices = ProductDetail.visible_to(current_user).find(params[:product_detail_id]).price_details
    render json: { data: serializer.group_by_supplier(prices) }, status: :ok
  end

  def create
    result = PriceDetailService::Creator.call(price_detail_params)
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
