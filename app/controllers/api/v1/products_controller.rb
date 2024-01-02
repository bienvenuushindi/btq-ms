class Api::V1::ProductsController < ApplicationController
  before_action :set_product, only: %i[show]

  def index
    products = Product.all
    products = products.search(params[:q]) if params[:q].present?
    products = products.by_status(params[:status]) if params[:status].present?
    products = products.reorder(sort_column => sort_direction)
    products = products.with_attached_images.order(created_at: :desc)
    paginated = paginate(products)

    products.present? ? render_collection(paginated) : :not_found
  end

  def count_by_status
    active_count = Product.count_by_status(true)
    inactive_count = Product.count_by_status(false)

    render json: {
      active: active_count,
      inactive: inactive_count
    }, status: :ok
  end

  def sort_column
    %w{name active created_at country_origin }.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    %w{asc desc }.include?(params[:direction]) ? params[:direction] : "desc"
  end

  def search
    products = nil
    paginated = nil
    options = {}
    if params[:q].present?
      # options[:include] =['product_details']
      options[:fields] = { product: [:name, :details] }
      products = Product.all.search(params[:q])
      products = products.order(created_at: :desc)
      paginated = paginate(products)
    end
    products.present? ? render_collection(paginated, options) : :not_found
  end

  def create
    product = Product.new(user: current_user,
                          name: product_params[:name],
                          short_description: product_params[:short_description],
                          description: product_params[:description],
                          active: product_params[:active],
                          country_origin: product_params[:country_origin],
                          images: product_params[:images],
    )
    product.tag_list = product_params[:tags] unless product_params[:tags].blank?

    if product.save
      render json: serializer.new(product), status: :created
    else
      render json: error_response(product)
    end
  end

  def show
    options = {}
    product = Product.find(params[:id])
    options[:include] = ['product_details']
    data = serializer.new(product, options)
    render json: data, status: :ok
  end

  def update
    product = Product.find(params[:id])

    update_product_attributes(product, product_params)

    if product.save
      render json: serializer.new(product), status: :ok
    else
      render json: error_response(product), status: :unprocessable_entity
    end
  end

  private

  def update_product_attributes(product, params)
    attributes_to_update = %i[name short_description description active country_origin tags images]

    attributes_to_update.each do |attribute_name|
      update_attribute(product, attribute_name, params[attribute_name])
    end
    # update_attribute(product, :name, params[:name])
    # update_attribute(product, :short_description, params[:short_description])
    # update_attribute(product, :description, params[:description])
    # update_attribute(product, :active, params[:active])
    # update_attribute(product, :country_origin, params[:country_origin])
    # update_attribute(product, :tags, params[:tags])
    # update_attribute(product, :images, params[:images])
  end

  def serializer
    ProductSerializer
  end

  def set_product
    Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :short_description, :description, :active, :country_origin, :tags, images: [])
  end
end
