class Api::V1::RequisitionsController < ApplicationController
  before_action -> { find_record(Requisition) }, only: %i[show]
  before_action :set_requisition, only: %i[update_products_list add_products remove_item]

  def index
    @requisition = RequisitionService::Retriever.call(Requisition.all, params)
    render_collection(paginate(@requisition), serializer)
  end

  def create
    render_serialized_resource(
      RequisitionService::Creator.call(requisition_params, current_user), serializer, :created
    )
  end

  def update_products_list
    if RequisitionService::Updater.call(@requisition, params)
      render json: serialize_resource(@requisition, serializer), status: :ok
    else
      render json: { error: 'Failed to update products list' }, status: :unprocessable_entity
    end
  end

  def add_products
    @requisition = RequisitionService::Creator.add_products(@requisition, params)
    if @requisition
      render json: serialize_resource(@requisition, serializer), status: :created
    else
      render json: error_response(@requisition)
    end
  end

  def show
    render json: serialize_resource(@requisition, serializer), status: :ok
  end

  def find_by_date
    record = RequisitionService::Reader.find_by_date(params)
    if record
      render json: serialize_resource(record, serializer), status: :ok
    else
      render json: {}, status: :not_found
    end
  rescue ArgumentError => e
    render json: { error: 'Invalid date format' }, status: :unprocessable_entity
  end

  def remove_item
    RequisitionService::Remover.remove_item(@requisition, params[:product_detail_id])
    head :no_content
  end

  private

  def set_requisition
    @requisition = Requisition::Reader.call(params[:id])
  end

  def serializer
    RequisitionSerializer
  end

  def update_requisition_params
    RequisitionService::Helper.update_requisition_params(params)
  end

  def requisition_params
    RequisitionService::Helper.requisition_params(params)
  end
end
