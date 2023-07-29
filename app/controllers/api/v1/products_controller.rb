class Api::V1::ProductsController < ApplicationController
  before_action :set_product, only: %i[show]

  def index
    products = Product.all
    products = products.search(params[:q]) if params[:q].present?
    products = products.with_attached_images.order(created_at: :desc)
    puts "=============================================================================="
    paginated = paginate(products)
    
    products.present? ? render_collection(paginated) : :not_found    
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
    if product.save
      render json: serializer.new(product), status: :created
    else
      render json: error_response(product)
    end
  end

  def show
    data = serializer.new(set_product)
    render json: data, status: :ok
  end

  private

  def serializer
    ProductSerializer
 end

  def set_product
    Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :short_description, :description, :active, :country_origin, images: [])
  end
end
