class Api::V1::SuppliersController < ApplicationController
  before_action :find_supplier, only: %i[show update]

  def index
    @suppliers = SupplierService::Retriever.call(Supplier.all, params)
    render_collection(paginate(@suppliers), serializer, SupplierService::Helper.index_options)
  end

  def create
    @supplier = SupplierService::Creator.call(supplier_params, current_user)
    render_serialized_resource(@supplier, serializer, :created)
  end

  def search
    @suppliers = SupplierService::Searcher.call(Supplier.all, params)
    render_collection(paginate(@suppliers), serializer, SupplierService::Helper.search_options)
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

  private

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
