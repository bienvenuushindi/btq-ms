class Api::V1::ProductDetailsController < ApplicationController
  before_action :set_product_detail, only: %i[show update]
  before_action :set_product, only: %i[index]

  def index
    options = {}
    render json: serialize_resources(data, serializer, options), status: :ok
    @product_details = ProductDetailService::Retriever.call(@product.product_details, params)
    render_collection(paginate(@product_details), serializer, ProductDetailService::Helper.index_options)
  end

  def expiring_soon
    render_collection(
      paginate(ProductDetailService::Retriever.expired_soon(params)),
      serializer,
      ProductDetailService::Helper.expiring_soon_options
    )
  end

  def expired
    render_collection(
      paginate(ProductDetailService::Retriever.expired(params)),
      serializer,
      ProductDetailService::Helper.expiring_soon_options
    )
  end

  def shelf_life_stats
    render json: {
      data: {
        expiring_soon: ProductDetail.count_expired_soon,
        expired: ProductDetail.count_expired
      }
    }, status: :ok
  end

  def create
    @product_detail = ProductDetailService::Creator.call(product_detail_params.merge(product_id: params[:product_id]))
    render_serialized_resource(@product_detail, serializer, :created)
  end

  def suppliers
    render json: serialize_resource(
      ProductDetailService::Reader.call(params[:id]),
      serializer, ProductDetailService::Helper.suppliers_options
    ), status: :ok
  end

  def show
    render json: serialize_resource(
      ProductDetailService::Reader.call(params[:id]),
      serializer
    ), status: :ok
  end

  def update
    if ProductDetailService::Updater.call(@product_detail, product_detail_params)
      render json: serialize_resource(@product_detail, serializer), status: :ok
    else
      render json: error_response(@product_detail), status: :unprocessable_entity
    end
  end

  private

  def serializer
    ProductDetailSerializer
  end

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_product_detail
    @product_detail = ProductDetail.find(params[:id])
  end

  def product_detail_params
    ProductDetailService::Helper.product_detail_params(params)
  end

end
