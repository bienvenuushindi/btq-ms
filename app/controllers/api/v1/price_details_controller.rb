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

  private

  def serializer
    PriceDetailSerializer
  end

  def price_detail_params
    PriceDetailService::Helper.price_detail_params(params)
  end
end
