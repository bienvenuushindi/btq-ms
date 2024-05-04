class Api::V1::SuppliersController < ApplicationController
  include CategoryHelper
  before_action -> { find_record(Supplier) }, only: %i[show update]

  def index
    suppliers = SupplierService::Retriever.call(Supplier.all, params)
    render_collection(paginate(suppliers), serializer, index_options)
  end

  def create
    @supplier = SupplierService::Creator.call(supplier_params, current_user)
    if @supplier.persisted?
      render json: serialize_resource(@supplier, serializer), status: :created
    else
      render json: error_response(@supplier), status: :unprocessable_entity
    end
  end
  def search
    suppliers = SupplierService::Searcher.call(Supplier.all, params)
    render_collection(paginate(suppliers), serializer, search_options)
  end
  def show
    render json: serialize_resource(@supplier, serializer), status: :ok
  end

  def update
    update_supplier
  end

  private


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
