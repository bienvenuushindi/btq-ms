class Api::V1::ProductDetailsController < ApplicationController
  before_action :set_product, only: %i[create index]

  def index
    product_details = set_product.product_details
    data = product_details.with_attached_images.order(created_at: :desc)
    render json: serializer.new(data), status: :ok
  end

  def create
    product_detail = ProductDetail.new(size: product_detail_params[:size],
                                       expired_date: product_detail_params[:expired_date],
                                       unit_price: product_detail_params[:unit_price],
                                       dozen_price: product_detail_params[:dozen_price],
                                       box_price: product_detail_params[:box_price],
                                       dozen_units: product_detail_params[:dozen_units],
                                       box_units: product_detail_params[:box_units],
                                       product: set_product,
                                       images: product_detail_params[:images]
    )
    if product_detail.save
      render json: created_response(product_detail), status: :created
    else
      render json: error_response(product_detail)
    end
  end

  def show
    render json: fetch_response(set_product_detail), status: :ok
  end

  private

  def serializer
    ProductDetailSerializer
  end

  def set_product
    Product.find(params[:product_id])
  end

  def product_detail_params
    params.require(:product_detail).permit(:size, :expired_date, :unit_price, :dozen_price, :box_price, :dozen_units, :box_units, images: [])
  end
end
