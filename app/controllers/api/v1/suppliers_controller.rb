class Api::V1::SuppliersController < ApplicationController
  before_action :set_supplier, only: %i[show]

  def index
    data =  SupplierSerializer.new(Supplier.all)
    render json: data, status: :ok
  end

  def create
    supplier = Supplier.new(shop_name: supplier_params[:shop_name], user: current_user)
    if supplier.save
      render json: created_response(supplier), status: :created
    else
      render json: error_response(supplier)
    end
  end

  def show
    render json: fetch_response(set_supplier), status: :ok
  end

  private

  def set_supplier
    Supplier.find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(:shop_name)
  end
end
