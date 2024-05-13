class Api::V1::RequisitionsController < ApplicationController
  before_action -> { find_record(Requisition) }, only: %i[show]
  before_action :set_requisition, only: %i[update_products_list add_products remove_item]

  def index
    options = { fields: { requisition: %i[id total_price count_products count_products_bought price_currency archived date] } }
    requisitions = Requisition.all
    requisitions = requisitions.search(params[:q]) if params[:q].present?
    requisitions = requisitions.order(created_at: :desc)
    paginated = paginate(requisitions)

    requisitions.present? ? render_collection(paginated, serializer, options) : :not_found
  end

  def create
    @requisition = Requisition.new(
      user: current_user,
      date: requisition_params[:date],
      price_currency: requisition_params[:currency]
    )
    if @requisition.save
      render json: serialize_resource(@requisition, serializer), status: :created
    else
      render json: error_response(@requisition)
    end
  end

  def update_products_list
    prod_req = @requisition.product_detail_requisitions.where(product_detail_id: params[:product_detail_id]).first
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
    render json: serialize_resource(@requisition, serializer), status: :ok
  end

  def add_products
    product_detail_ids = product_details_ids
    existing_product_detail_ids = @requisition.product_details.where(id: product_detail_ids).pluck(:id)
    new_product_detail_ids = product_detail_ids - existing_product_detail_ids

    new_product_details = ProductDetail.where(id: new_product_detail_ids)
    @requisition.product_details << new_product_details

    if (data = serialize_resource(@requisition, serializer))
      render json: data, status: :created
    else
      render json: error_response(@requisition)
    end
  end


  def show
    render json: serialize_resource(@requisition, serializer), status: :ok
  end


  def find_by_date
    date_to_search = Date.parse(params[:date])
    record = Requisition.find_by_date(date_to_search)
    if record.present?
      render json: serialize_resource(record, serializer), status: :ok
    else
      render json: {}, status: :not_found
    end
  rescue ArgumentError => e
    render json: { error: 'Invalid date format' }, status: :unprocessable_entity
  end


  def remove_item
    product_detail = ProductDetail.find(params[:product_detail_id])
    ProductDetailRequisition.where(requisition: @requisition, product_detail: product_detail).destroy_all
    head :no_content
  end

  private

  def set_requisition
    @requisition = Requisition.find(params[:id])
  end

  def serializer
    RequisitionSerializer
  end

  def product_details_ids
    requisition_params.fetch(:product_detail_ids, [])
  end

  def update_requisition_params
    params.require(:requisition_product).permit(:price, :currency, :status, :quantity, :quantity_type, :note, :supplier_id, :expired_date)
  end

  def requisition_params
    params.require(:requisition).permit(:date, :currency, product_detail_ids: [])
  end
end
