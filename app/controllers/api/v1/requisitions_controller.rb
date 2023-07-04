class Api::V1::RequisitionsController < ApplicationRecord
  before_action :set_requisition, only: %i[show]

  def index
    render json: fetch_response(Requisition.all), status: :ok
  end

  def create
    requisition = Requisition.new(requisition_params)
    if requisition.save
      render json: created_response(requisition), status: :created
    else
      render json: error_response(requisition)
    end
  end

  def show
    render json: fetch_response(set_requisition), status: :ok
  end

  private

  def set_requisition
    Requisition.find(params[:id])
  end

  def requisition_params
    params.require(:requisition).permit()
  end
end
