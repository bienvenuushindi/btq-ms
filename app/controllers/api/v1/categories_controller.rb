class Api::V1::CategoriesController < ApplicationController
  before_action :set_category, only: %i[show destroy]

  def index
    categories = Category.all
    categories = categories.search(params[:q]) if params[:q].present?
    categories = categories.reorder(sort_column => sort_direction)
    paginated = paginate(categories)
    
    categories.present? ? render_collection(paginated) : :not_found
  end

  def sort_column
    %w{name active created_at count_products }.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    %w{asc desc }.include?(params[:direction]) ? params[:direction] : "desc"
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

  def tree_structure
    # options = {}
    # options[:is_collection]=true
    # options[:fields] = { category: [:id, :name, :children]}
    categories_tree = Category.tree_structure

    render json: {data:categories_tree}, status: :ok
  end

  private

  def serializer
    CategorySerializer
  end

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description, :active, :parent_category_id)
  end
end
