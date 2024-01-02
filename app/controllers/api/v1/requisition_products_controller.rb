class Api::V1::RequisitionProductsController < ApplicationController

  def quantity_types
    render json: {data:ProductDetailRequisition.reverse_quantity_types}, status: :ok
  end
  def currencies
    render json: {data:ProductDetailRequisition.currencies}, status: :ok
  end
end
