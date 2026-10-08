class Api::V1::CategoriesController < ApplicationController
  before_action :require_admin!, only: %i[create update destroy]
  before_action :find_category, only: %i[show destroy update]

  def index
    @categories = CategoryService::Retriever.call(Category.all, params)
    render_collection(paginate(@categories), serializer, serializer_options)
  end

  def create
    @category = CategoryService::Creator.call(category_params)
    render_serialized_resource(@category, serializer, :created)
  end

  def show
    render json: serialize_resource(@category, serializer, serializer_options), status: :ok
  end

  def update
    if CategoryService::Updater.call(@category, category_params)
      render json: serialize_resource(@category, serializer), status: :ok
    else
      render json: error_response(@category, 'Failed to update the product'), status: :unprocessable_entity
    end
  end

  def destroy
    if @category.children.exists? || @category.categorizations.exists? || @category.customer_preferences.exists?
      render json: { error: 'Category cannot be deleted while it is in use' }, status: :unprocessable_entity
      return
    end

    @category.destroy!
    head :no_content
  end

  def tree_structure
    categories_tree = Category.tree_structure
    render json: { data: categories_tree }, status: :ok
  end

  def parents
    render json:  serialize_resources(Category.parent_categories, serializer, serializer_options(%i[id name count_products description image_url selected_variants_count market_variants_count]))
  end

  private

  def serializer
    CategorySerializer
  end

  def serializer_options(fields = serializer.fields)
    { params: { current_user: current_user, fields: fields }, fields: { category: fields } }
  end

  def category_params
    CategoryService::Helper.product_params(params)
  end

  def find_category
    @category = CategoryService::Reader.call(params[:id])
  end
end
