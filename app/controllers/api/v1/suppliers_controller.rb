class Api::V1::SuppliersController < ApplicationController
  include CategoryHelper
  before_action -> { find_record(Supplier) }, only: %i[show update]

  def index
    render_collection(paginated_suppliers, serializer, index_options)
  end

  def search
    render_collection(paginated_search_results, serializer, search_options)
  end

  def create
    create_supplier
  end

  def show
    render json: serialize_resource(@supplier, serializer), status: :ok
  end

  def update
    update_supplier
  end

  private

  def paginated_suppliers
    suppliers = Supplier.all
    suppliers = suppliers.search(params[:q]) if params[:q].present?
    suppliers = suppliers.reorder(sort_column => sort_direction)
    suppliers = suppliers.with_attached_images.order(created_at: :desc)
    paginate(suppliers)
  end

  def sort_column
    %w[shop_name created_at].include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  def paginated_search_results
    return unless params[:q].present?

    suppliers = Supplier.all.search(params[:q]).limit(4)
    filter_suppliers_by_product_detail(suppliers) if params[:product_detail_id].present?
    suppliers = suppliers.order(created_at: :desc)
    paginate(suppliers)
  end

  def filter_suppliers_by_product_detail(suppliers)
    prod_supplier_ids = ProductDetail.find_by(id: params[:product_detail_id]).suppliers.pluck(:id)
    suppliers.where.not(id: prod_supplier_ids)
  end

  def create_supplier
    @supplier = SupplierService::Creator.call(supplier_params, current_user)
    if @supplier.persisted?
      render json: serialize_resource(@supplier, serializer), status: :created
    else
      render json: error_response(@supplier), status: :unprocessable_entity
    end
  end

  def update_supplier
    update_supplier_attributes(@supplier, supplier_params)
    if @supplier.save
      render json: serialize_resource(@supplier, serializer), status: :ok
    else
      render json: error_response(@supplier), status: :unprocessable_entity
    end
  end

  def update_supplier_attributes(supplier, params)
    update_attribute(supplier, :shop_name, params[:shop_name])
    update_attribute(supplier, :tags, params[:tags])
    update_attribute(supplier, :images, params[:images])
    update_attribute(supplier, :address, params)
    categories = parse_category_ids(params[:categories])
    update_categories(supplier, categories)
  end

  def index_options
    { fields: { supplier: [:id, :shop_name, :image_urls, :address] } }
  end

  def search_options
    { fields: { supplier: [:id, :shop_name, :image_urls, :address, :categories] } }
  end

  def serializer
    SupplierSerializer
  end

  def supplier_params
    params.require(:supplier).permit(:shop_name, :address1, :address2, :city, :tel1, :country_name, :tel2, :country_id, :tags, :categories, images: [])
  end
end
