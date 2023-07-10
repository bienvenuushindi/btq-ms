class Api::V1::CategoriesController < ApplicationController
  before_action :set_category, only: %i[show destroy]

  def index
    render json: fetch_response(Category.all), status: :ok
  end

  def create
    @category = Category.new(
      name: category_params[:name],
      description: category_params[:description],
      active: category_params[:active],
      parent_category_id: category_params[:parent_category_id]
    )

    if @category.save
      render json: created_response(@category), status: :created
    else
      render json: error_response(@category), status: :unprocessable_entity
    end
  end

  def show
    render json: fetch_response(@category), status: :ok
  end

  def destroy
    @category.destroy
    head :no_content
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description, :active, :parent_category_id)
  end
end
