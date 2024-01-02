class Api::V1::ProductDetailsController < ApplicationController
  before_action :set_product, only: %i[create index]

  def index
    product_details = set_product.product_details
    data = product_details.with_attached_images.order(created_at: :desc)
    render json: serializer.new(data), status: :ok
  end

  def expiring_soon
    options = {}
    options[:meta] = { count: ProductDetail.count_expired_soon }
    options[:fields] = { product_detail: [:id, :size, :expired_date, :product_name, :image_urls] }
    products = ProductDetail.expired_soon
    products = products.last_soon_expired(params.fetch(:limit, 5)) if params[:limit].present?
    render json: serializer.new(products, options), status: :ok
  end

  def expired
    options = {}
    options[:meta] = { count: ProductDetail.count_expired }
    options[:fields] = { product_detail: [:id, :size, :expired_date, :product_name, :image_urls] }
    products = ProductDetail.expired
    products = products.last_expired(params.fetch(:limit, 5)) if params[:limit].present?
    render json: serializer.new(products, options), status: :ok
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
                                       status: product_detail_params[:status],
                                       images: product_detail_params[:images]
    )
    product_detail.tag_list = product_detail_params[:tags] unless product_detail_params[:tags].blank?
    if product_detail.save
      render json: created_response(product_detail), status: :created
    else
      render json: error_response(product_detail)
    end
  end

  def suppliers
    options = {}
    options[:fields] = { product_detail: [:suppliers] }
    render json: serializer.new(set_product_detail, options), status: :ok
  end

  def show
    product = ProductDetail.find(params[:id])
    data = serializer.new(product)
    render json: data, status: :ok
  end

  def update
    product_detail = ProductDetail.find(params[:id])
    update_product_attributes(product_detail, product_detail_params)
    if product_detail.save
      render json: serializer.new(product_detail), status: :ok
    else
      render json: error_response(product_detail), status: :unprocessable_entity
    end
  end

  private

  def update_product_attributes(product_detail, params)
    update_attribute(product_detail, :size, params[:size])
    update_attribute(product_detail, :expired_date, params[:expired_date])
    update_attribute(product_detail, :unit_price, params[:unit_price])
    update_attribute(product_detail, :dozen_price, params[:dozen_price])
    update_attribute(product_detail, :box_price, params[:box_price])
    update_attribute(product_detail, :box_units, params[:box_units])
    update_attribute(product_detail, :dozen_units, params[:dozen_units])
    update_attribute(product_detail, :currency, params[:currency])
    update_attribute(product_detail, :status, params[:status])
    update_attribute(product_detail, :images, params[:images])
    update_attribute(product_detail, :tags, params[:tags])
  end

  def serializer
    ProductDetailSerializer
  end

  def set_product_detail
    ProductDetail.find(params[:id])
  end

  def set_product
    Product.find(params[:product_id])
  end

  def product_detail_params
    params.require(:product_detail).permit(:size, :expired_date, :currency, :status, :unit_price, :dozen_price, :box_price, :dozen_units, :tags, :box_units, :supplier_id, images: [])
  end
end
