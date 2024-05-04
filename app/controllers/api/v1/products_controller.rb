class Api::V1::ProductsController < ApplicationController
  include CategoryHelper
  before_action -> { find_record(Product) }, only: %i[show update]

  def index
    products = ProductService::Retriever.call(Product.all, params)
    render_collection(paginate(products), serializer)
  end

  def search
    products = ProductService::Searcher.call(Product.all, params)
    render_collection(paginate(products), serializer, search_options)
  end

  def count_by_status
    active_count = Product.count_by_status(true)
    inactive_count = Product.count_by_status(false)

    render json: { data: {
      active: active_count,
      inactive: inactive_count
    } }, status: :ok
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
    options = { include: ['product_details'] }
    render json: serialize_resource(@product, serializer, options), status: :ok
  end

  def update
    Product.transaction do
      update_product_attributes(@product, product_params)
      if @product.save
        render json: serialize_resource(@product, serializer), status: :ok
      else
        render json: error_response(@product, 'Failed to update the product'), status: :unprocessable_entity
      end
    end
  end

  private
  def update_product_attributes(product, params)
    attributes_to_update = %i[name short_description description active country_origin tags images categories]

    attributes_to_update.each do |attribute_name|
      if attribute_name.to_sym == :categories && params[attribute_name].present?
        categories = parse_category_ids(params[attribute_name])
        update_categories(product, categories)
      else
        update_attribute(product, attribute_name, params[attribute_name])
      end
    end
  end

  def search_options
    { fields: { product: %i[name details] } }
  end

  def serializer
    ProductSerializer
  end

  def product_params
    params.require(:product).permit(:name, :short_description, :description, :active, :country_origin, :tags, :categories, images: [])
  end
end
