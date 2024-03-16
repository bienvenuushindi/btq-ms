class Api::V1::ProductDetailsController < ApplicationController
  before_action -> { find_record(ProductDetail) }, only: %i[show update]
  before_action :set_product, only: %i[create index]

  def index
    options = {}
    product_details = @product.product_details
    options[:fields] = { product_detail: %i[id size currency expired_date dozen_units box_units created_at image_urls status product_name] }
    data = product_details.with_attached_images.order(created_at: :desc)
    render json: serialize_resources(data, serializer, options), status: :ok
  end

  def expiring_soon
    options = {}
    options[:meta] = { count: ProductDetail.count_expired_soon }
    options[:fields] = { product_detail: %i[:id size expired_date product_name image_urls] }
    products = ProductDetail.expired_soon
    products = products.last_soon_expired(params.fetch(:limit, 5)) if params[:limit].present?
    render json: serialize_resources(products, serializer, options), status: :ok
  end

  def expired
    options = {}
    options[:meta] = { count: ProductDetail.count_expired }
    options[:fields] = { product_detail: %i[:id size expired_date product_name image_urls] }
    products = ProductDetail.expired
    products = products.last_expired(params.fetch(:limit, 5)) if params[:limit].present?
    render json: serialize_resources(products, serializer, options), status: :ok
  end

  def create
    @product_detail = ProductDetail.new(size: product_detail_params[:size],
                                       expired_date: product_detail_params[:expired_date],
                                       unit_price: product_detail_params[:unit_price],
                                       dozen_price: product_detail_params[:dozen_price],
                                       box_price: product_detail_params[:box_price],
                                       dozen_units: product_detail_params[:dozen_units],
                                       box_units: product_detail_params[:box_units],
                                       product: @product,
                                       status: product_detail_params[:status],
                                       images: product_detail_params[:images]
    )
    @product_detail.tag_list = product_detail_params[:tags] unless product_detail_params[:tags].blank?
    if @product_detail.save
      render json: serialize_resource(@product_detail, serializer), status: :created
    else
      render json: error_response(@product_detail)
    end
  end

  def suppliers
    options = {}
    options[:fields] = { product_detail: [:suppliers] }
    render json: serialize_resource(ProductDetail.find(params[:id]), serializer, options), status: :ok
  end

  def show
    render json: serialize_resource(@product_detail, serializer), status: :ok
  end

  def update
    update_product_attributes(@product_detail, product_detail_params)
    if @product_detail.save
      render json: serialize_resource(@product_detail, serializer), status: :ok
    else
      render json: error_response(@product_detail), status: :unprocessable_entity
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

  def set_product
    @product = Product.find(params[:product_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Product not found' }, status: :not_found
  end

  def product_detail_params
    params.require(:product_detail).permit(:size, :expired_date, :currency, :status, :unit_price, :dozen_price, :box_price, :dozen_units, :tags, :box_units, :supplier_id, images: [])
  end
end
