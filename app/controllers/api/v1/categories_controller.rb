class Api::V1::CategoriesController < ApplicationController
  before_action -> { find_record(Category) }, only: %i[show destroy update]

  def index
    categories = Category.all
    categories = categories.search(params[:q]) if params[:q].present?
    categories = categories.reorder(sort_column => sort_direction)
    paginated = paginate(categories)

    categories.present? ? render_collection(paginated, serializer) : :not_found
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
      parent_category_id: category_params[:parent_category_id] == 'null' ? nil : category_params[:parent_category_id]
    )

    if @category.save
      render json: serialize_resource(@category, serializer), status: :created
    else
      render json: error_response(@category), status: :unprocessable_entity
    end
  end

  def show
    render json: serialize_resource(@category, serializer), status: :ok
  end

  def update
    Category.transaction do
      update_category_attributes(@category, category_params)

      if @category.save
        render json: serialize_resource(@category, serializer), status: :ok
      else
        render json: error_response(@category, 'Failed to update the product'), status: :unprocessable_entity
      end
    end
  end

  def destroy
    @category.destroy
    head :no_content
  end

  def tree_structure
    categories_tree = Category.tree_structure
    render json: { data: categories_tree }, status: :ok
  end

  private

  def serializer
    CategorySerializer
  end

  def category_params
    params.require(:category).permit(:name, :description, :active, :parent_category_id)
  end

  def update_category_attributes(category, params)
    attributes_to_update = %i[name description active parent_category_id]

    attributes_to_update.each do |attribute_name|
      update_attribute(category, attribute_name, params[attribute_name])
    end
  end
end
