class Api::V1::ProductsController < ApplicationController
  include CategoryHelper
  before_action -> { find_record(Product) }, only: %i[show update]

  def index
    render_collection(paginated_products, serializer)
  end

  def count_by_status
    active_count = Product.count_by_status(true)
    inactive_count = Product.count_by_status(false)

    render json: { data: {
      active: active_count,
      inactive: inactive_count
    } }, status: :ok
  end

  def search
    render_collection(paginated_search_results, serializer, search_options)
  end

  def create
    create_product
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

  def paginated_search_results
    return unless params[:q].present?

    products = Product.all.search(params[:q])
    products = products.order(created_at: :desc)
    paginated = paginate(products)

    paginated.present? ? paginated : { error: 'No products found' }
  end

  def search_options
    { fields: { product: %i[name details] } }
  end

  def sort_column
    %w[name active created_at country_origin].include?(params[:sort]) ? params[:sort] : 'created_at'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
  end

  def paginated_products
    products = Product.all
    products = products.search(params[:q]) if params[:q].present?
    products = products.by_status(params[:status]) if params[:status].present?
    products = products.reorder(sort_column => sort_direction)
    products = products.with_attached_images.order(created_at: :desc)
    paginate(products)
  end

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

  def serializer
    ProductSerializer
  end

  def create_product
    @product = ProductService::Creator.call(product_params, current_user)
    if @product.persisted?
      render json: serialize_resource(@product, serializer), status: :created
    else
      render json: error_response(@product), status: :unprocessable_entity
    end
  end

  def product_params
    params.require(:product).permit(:name, :short_description, :description, :active, :country_origin, :tags, :categories, images: [])
  end
end
