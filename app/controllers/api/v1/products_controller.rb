class Api::V1::ProductsController < ApplicationController
  before_action :set_product, only: %i[show]

  def index
    data = ProductSerializer.new(Product.all)
    render json: data , status: :ok
  end

  def create
    product = Product.new(user: current_user,
                          name: product_params[:name],
                          short_description: product_params[:short_description],
                          description: product_params[:description],
                          active: product_params[:active],
                          country_origin: product_params[:country_origin],
    )
    if product.save
      render json: created_response(product), status: :created
    else
      render json: error_response(product)
    end
  end

  def show
    data = ProductSerializer.new(set_product)
    render json: data, status: :ok
  end

  private

  def set_product
    Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :short_description, :description, :active, :country_origin)
  end
end
