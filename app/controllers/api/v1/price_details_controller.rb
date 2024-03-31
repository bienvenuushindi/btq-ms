class Api::V1::PriceDetailsController < ApplicationController
  def index
    product_detail = ProductDetail.find_by(id: params[:product_detail_id])
    prices = product_detail.price_details
    render json: {data: PriceDetailSerializer.group_by_supplier(prices)}, status: :ok
  end

  def create
    prices_hash = price_detail_params[:prices].to_h
    success = PriceDetail.custom_upsert(prices_hash, price_detail_params[:currency], price_detail_params[:supplier_id], price_detail_params[:product_detail_id])
    if success
      render json: { status: 'success' }, status: :ok
    else
      render json: { status: 'error' }, status: :unprocessable_entity
    end
  end

  def show
    render json: serialize_resource(PriceDetail.find(params[:id]), serializer), status: :ok
  end

  private

  def serializer
    PriceDetailSerializer
  end

  def price_detail_params
    params.require(:price_detail).permit(:supplier_id, :currency, :product_detail_id, prices: [:box, :dozen, :unit])
  end
end
