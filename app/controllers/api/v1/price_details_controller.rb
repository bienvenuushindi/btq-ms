class Api::V1::PriceDetailsController < ApplicationController
  before_action :set_price_detail, only: %i[show]

  def index
    prices = PriceDetail.where(product_detail_id: params[:product_detail_id])
    grouped_by_supplier = PriceDetailSerializer.group_by_supplier(prices)
    render json: grouped_by_supplier, status: :ok
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
    render json: fetch_response(set_price_detail), status: :ok
  end

  private

  def serializer
    PriceDetailSerializer
  end

  def set_price_detail
    PriceDetail.find(params[:id])
  end

  def price_detail_params
    params.require(:price_detail).permit(:supplier_id, :currency, :product_detail_id, prices: [:box, :dozen, :unit])
  end
end
