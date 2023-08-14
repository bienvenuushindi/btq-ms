class Api::V1::PriceDetailsController < ApplicationController
  before_action :set_price_detail, only: %i[show]

  def index
    data = PriceDetailSerializer.new(PriceDetail.where(product_detail_id: params[:product_detail_id]))
    render json: data, status: :ok
  end

  def create
    price_detail = PriceDetail.new(price_detail_params)
    if price_detail.save
      render json: created_response(price_detail), status: :created
    else
      render json: error_response(price_detail)
    end
  end

  def show
    render json: fetch_response(set_price_detail), status: :ok
  end

  private

  def set_price_detail
    PriceDetail.find(params[:id])
  end

  def price_detail_params
    params.require(:price_detail).permit(:dozen, :box, :currency, :supplier_id, :product_detail_id)
  end
end
