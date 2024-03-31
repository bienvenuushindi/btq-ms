class Api::V1::ProductsController < ApplicationController
  before_action -> { find_record(Product) }, only: %i[show update]

  def index
    products = Product.all
    products = products.search(params[:q]) if params[:q].present?
    products = products.by_status(params[:status]) if params[:status].present?
    products = products.reorder(sort_column => sort_direction)
    products = products.with_attached_images.order(created_at: :desc)
    paginated = paginate(products)

    if products.present?
      render_collection(paginated,serializer)
    else
      render json: { error: 'No products found' }, status: :not_found
    end
  end

  def count_by_status
    active_count = Product.count_by_status(true)
    inactive_count = Product.count_by_status(false)

    render json: {data: {
      active: active_count,
      inactive: inactive_count
    }}, status: :ok
  end

  def sort_column
    %w[name active created_at country_origin].include?(params[:sort]) ? params[:sort] : 'created_at'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
  end

  def search
    products = nil
    paginated = nil
    options = {}
    if params[:q].present?
      options[:fields] = { product: %i[name details] }
      products = Product.all.search(params[:q])
      products = products.order(created_at: :desc)
      paginated = paginate(products)
    end
    if products.present?
      render_collection(paginated, serializer, options)
    else
      render json: { error: 'No products found' }, status: :not_found
    end
  end

  def create
    @product = build_product_from_params

    if @product.save
      render json: serialize_resource(@product, serializer), status: :created
    else
      render json: error_response(@product, 'Failed to create the product'), status: :unprocessable_entity
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
    attributes_to_update = %i[name short_description description active country_origin tags images]

    attributes_to_update.each do |attribute_name|
      update_attribute(product, attribute_name, params[attribute_name])
    end
  end

  def serializer
    ProductSerializer
  end

  def build_product_from_params
    Product.new(
      user: current_user,
      name: product_params[:name],
      short_description: product_params[:short_description],
      description: product_params[:description],
      active: product_params[:active],
      country_origin: product_params[:country_origin],
      images: product_params[:images]
    ).tap { |product| product.tag_list = product_params[:tags] unless product_params[:tags].blank? }
  end

  def product_params
    params.require(:product).permit(:name, :short_description, :description, :active, :country_origin, :tags, images: [])
  end
end
