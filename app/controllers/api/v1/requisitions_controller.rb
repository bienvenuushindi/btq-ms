class Api::V1::RequisitionsController < ApplicationController
  before_action :set_requisition, only: %i[show]

  def index
    options = {}
    options[:fields] = { requisition: [:total_price, :count_products, :count_products_bought, :price_currency, :archived, :date] }
    requisitions = Requisition.all
    requisitions = requisitions.search(params[:q]) if params[:q].present?
    requisitions = requisitions.order(created_at: :desc)
    paginated = paginate(requisitions)

    requisitions.present? ? render_collection(paginated, options) : :not_found
  end

  def create
    requisition = Requisition.new(
      user: current_user,
      date: requisition_params[:date],
      price_currency: requisition_params[:currency]
    )
    if requisition.save
      options = {}
      # options[:include] = ['product_details']
      data = serializer.new(requisition, options)
      render json: data, status: :created
    else
      render json: error_response(requisition)
    end
  end

  def update_products_list
    prod_req = set_requisition.product_detail_requisitions.where(product_detail_id: params[:product_detail_id]).first
    prod_req.decrement_total_price
    result = prod_req.update(update_requisition_params)
    if result
      price = update_requisition_params[:price]
      currency = update_requisition_params[:currency]
      supplier_id = update_requisition_params[:supplier_id]
      product_detail_id = params[:product_detail_id]
      quantity_type = update_requisition_params[:quantity_type]
      PriceDetail.custom_upsert({ quantity_type => price }, currency, supplier_id, product_detail_id)
    end
    data = serializer.new(set_requisition)
    render json: data, status: :ok
  end

  def add_products
    requisition = Requisition.find(params[:id])
    product_details_ids.each do |product_detail_id|
      product_detail = ProductDetail.find(product_detail_id)
      # Check if the product_detail is not already associated with the requisition
      unless requisition.product_details.exists?(product_detail.id)
        requisition.product_details << product_detail
      end
    end
    if (data = serializer.new(requisition))
      render json: data, status: :created
    else
      render json: error_response(requisition)
    end
  end

  def show
    options = {}
    render json: serializer.new(set_requisition, options), status: :ok
  end

  def find_by_date
    date_to_search = Date.parse(params[:date])
    records = Requisition.find_by_date(date_to_search)
    render json: serializer.new(records), status: :ok
  end

  def remove_item
    requisition = Requisition.find(params[:id])
    product_detail = ProductDetail.find(params[:product_detail_id])
    ProductDetailRequisition.where(requisition: requisition, product_detail: product_detail).destroy_all

    head :no_content
  end

  private

  def set_requisition
    Requisition.find(params[:id])
  end

  def serializer
    RequisitionSerializer
  end

  def product_details_ids
    requisition_params.fetch(:product_detail_ids, [])
  end

  def update_requisition_params
    params.require(:requisition_product).permit(:price, :currency, :found, :quantity, :quantity_type, :note, :supplier_id, :expired_date)
  end

  def requisition_params
    params.require(:requisition).permit(:date, :currency, product_detail_ids: [])
  end
end
