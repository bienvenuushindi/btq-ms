class Api::V1::RequisitionsController < ApplicationController
  before_action :set_requisition, only: %i[show]

  def index
    render json: fetch_response(Requisition.all), status: :ok
  end

  def create
    requisition = Requisition.new(
      user: current_user,
      date: requisition_params[:date]
    )
    if requisition.save
      options = {}
      options[:include] = ['product_details']
      data = serializer.new(requisition, options)
      render json: data, status: :created
    else
      render json: error_response(requisition)
    end
  end

  def update

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
    if requisition
      data = serializer.new(requisition)
      render json: data, status: :created
    else
      render json: error_response(requisition)
    end
  end

  def show
    options = {}
    # options[:include] =['product_details']
    data = serializer.new(set_requisition, options)
    render json: data, status: :ok
  end

  def remove_item
    requisition = Requisition.find(params[:id])
    product_detail = ProductDetail.find(params[:product_detail_id])
    item = ProductDetailRequisition.where(requisition: requisition, product_detail: product_detail).destroy_all

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

  def requisition_params
    params.require(:requisition).permit(:date, product_detail_ids: [])
  end
end
