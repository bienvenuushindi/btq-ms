class Api::V1::SuppliersController < ApplicationController
  before_action :require_admin!, only: %i[create update]
  before_action :find_supplier, only: %i[show update products]

  def index
    @suppliers = SupplierService::Retriever.call(suppliers_visible_to_current_user, params)
    render_collection(paginate(@suppliers), serializer, SupplierService::Helper.index_options)
  end

  def create
    @supplier = SupplierService::Creator.call(supplier_params, current_user)
    render_serialized_resource(
      @supplier,
      serializer,
      :created,
      params: { include_temporary_password: true }
    )
  end

  def search
    @suppliers = SupplierService::Searcher.call(Supplier.all, params)
    render_collection(
      paginate(@suppliers),
      serializer,
      SupplierService::Helper.search_options(params[:product_detail_id])
    )
  end

  def show
    render json: serialize_resource(@supplier, serializer), status: :ok
  end

  def update
    if SupplierService::Updater.call(@supplier, supplier_params)
      render json: serialize_resource(@supplier, serializer), status: :ok
    else
      render json: error_response(@supplier), status: :unprocessable_entity
    end
  end

  def products
    selected_product_ids = ProductDetail
      .joins(:supplier_product_details)
      .where(supplier_product_details: { supplier_id: @supplier.id, supplier_status: true })
      .select(:product_id)
    priced_product_ids = ProductDetail
      .joins(:price_details)
      .merge(PriceDetail.supplier_active.where(supplier_id: @supplier.id))
      .select(:product_id)
    products = Product.where(id: selected_product_ids).or(Product.where(id: priced_product_ids))
    products = products.search(params[:q]) if params[:q].present?
    products = products.order(name: :asc, id: :asc).with_attached_images

    render_collection(
      paginate(products),
      ProductSerializer,
      params: { current_user: current_user, supplier_shop_id: @supplier.id }
    )
  end

  private

  def suppliers_visible_to_current_user
    return Supplier.all unless current_user.supplier?

    Supplier.bought_from_by(current_user)
  end

  def find_supplier
    @supplier = SupplierService::Reader.call(params[:id])
  end

  def serializer
    SupplierSerializer
  end

  def supplier_params
    SupplierService::Helper.supplier_params(params)
  end
end
