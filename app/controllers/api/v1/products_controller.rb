class Api::V1::ProductsController < ApplicationController
  before_action :find_product, only: %i[show update]

  def index
    @products = ProductService::Retriever.call(Product.all, params)
    render_collection(paginate(@products), serializer)
  end

  def search
    @products = ProductService::Searcher.call(Product.all, params)
    render_collection(paginate(@products), serializer, ProductService::Options.search)
  end

  def count_by_status
    counts = ProductService::StatusCounter.call
    render json: { data: counts }, status: :ok
  end

  def create
    @product = ProductService::Creator.call(product_params, current_user)
    if @product.persisted?
      render json: serialize_resource(@product, serializer), status: :created
    else
      render json: error_response(@product), status: :unprocessable_entity
    end
  end

  def show
    render json: serialize_resource(@product, serializer), status: :ok
  end

  def update
    if ProductService::Updater.call(@product, product_params)
      render json: serialize_resource(@product, serializer), status: :ok
    else
      render json: error_response(@product, 'Failed to update the product'), status: :unprocessable_entity
    end
  end

  private

  def find_product
    @product = ProductService::Reader.call(params[:id])
  end

  def serializer
    ProductSerializer
  end

  def product_params
    ProductService::Params.product_params(params)
  end
end
