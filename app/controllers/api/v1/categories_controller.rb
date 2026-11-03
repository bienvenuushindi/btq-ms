class Api::V1::CategoriesController < ApplicationController
  before_action :require_supplier_profile!, only: %i[shop select_for_shop remove_from_shop]
  before_action :require_admin!, only: %i[create update destroy]
  before_action :find_category, only: %i[show destroy update]

  def index
    @categories = CategoryService::Retriever.call(Category.all, params)
    render_collection(paginate(@categories), serializer, serializer_options)
  end

  # Flat lists for shop selection and horizontal product filters.
  def catalog
    render json: serialize_resources(Category.order(:name), serializer, flat_serializer_options)
  end

  def shop
    render json: serialize_resources(@shop.categories.distinct.order(:name), serializer, flat_serializer_options)
  end

  def select_for_shop
    category = Category.active.find(params[:category_id])
    @shop.with_lock do
      @shop.categorizations.find_or_create_by!(category: category)
    end
    render json: serialize_resource(category, serializer, flat_serializer_options), status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'An active category was not found' }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
  end

  def remove_from_shop
    @shop.categorizations.where(category_id: params[:category_id]).destroy_all
    head :no_content
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

  def require_supplier_profile!
    unless current_user.supplier?
      render json: { error: 'Only suppliers can select shop categories' }, status: :forbidden
      return
    end
    @shop = current_user.suppliers.order(:created_at).first
    render json: { error: 'Supplier profile was not found' }, status: :unprocessable_entity unless @shop
  end

  def flat_serializer_options
    serializer_options(%i[id name description active selected_variants_count market_variants_count])
  end

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
