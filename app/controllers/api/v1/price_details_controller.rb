class Api::V1::PriceDetailsController < ApplicationController
  def index
    prices = ProductDetailService::Reader.call(params[:product_detail_id]).price_details
    render json: { data: serializer.group_by_supplier(prices) }, status: :ok
  end

  def create
    if PriceDetailService::Creator.call(price_detail_params)
      render json: { status: 'success' }, status: :ok
    else
      render json: { status: 'error' }, status: :unprocessable_entity
    end
  end

  def show
    render json: serialize_resource(PriceDetailService::Reader.call(params[:id]), serializer), status: :ok
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
end
