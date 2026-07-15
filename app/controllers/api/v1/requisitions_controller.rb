class Api::V1::RequisitionsController < ApplicationController
  before_action :find_visible_requisition, only: %i[show update]
  before_action :set_requisition, only: %i[update_products_list add_products remove_item]

  def index
    @requisition = RequisitionService::Retriever.call(visible_requisitions, params)
    render_collection(paginate(@requisition), serializer, serializer_options)
  end

  def create
    render_serialized_resource(
      RequisitionService::Creator.call(requisition_params, current_user), serializer, :created, serializer_options
    )
  end

  def update_products_list
    if RequisitionService::Updater.call(@requisition, params)
      render json: serialize_resource(@requisition, serializer, serializer_options), status: :ok
    else
      render json: error_response(@requisition, 'Failed to update products list. ' + @requisition.errors.full_messages.to_sentence), status: :unprocessable_entity
    end
  end

  def add_products
    @requisition = RequisitionService::Creator.add_products(@requisition, params)
    if @requisition.errors.empty?
      render json: serialize_resource(@requisition, serializer, serializer_options), status: :created
    else
      render json: error_response(@requisition), status: :unprocessable_entity
    end
  end

  def show
    render json: serialize_resource(@requisition, serializer, serializer_options), status: :ok
  end

  def update
    if @requisition.update(requisition_update_params)
      render json: serialize_resource(@requisition, serializer, serializer_options), status: :ok
    else
      render json: error_response(@requisition, 'Failed to update requisition. ' + @requisition.errors.full_messages.to_sentence), status: :unprocessable_entity
    end
  end

  def find_by_date
    record = RequisitionService::Reader.find_by_date(params, visible_requisitions)
    if record
      render json: serialize_resource(record, serializer, serializer_options), status: :ok
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
    @requisition = visible_requisitions.find(params[:id])
  end

  def find_visible_requisition
    @requisition = visible_requisitions.find(params[:id])
  end

  def visible_requisitions
    Requisition.visible_to(current_user)
  end

  def serializer_options
    { params: { current_user: current_user } }
  end

  def serializer
    RequisitionSerializer
  end

  def update_requisition_params
    RequisitionService::Helper.update_requisition_params(params)
  end

  def requisition_update_params
    params.require(:requisition).permit(:archived)
  end

  def requisition_params
    RequisitionService::Helper.requisition_params(params)
  end
end
