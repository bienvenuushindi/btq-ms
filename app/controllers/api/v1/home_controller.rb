class Api::V1::HomeController < ApplicationController

  def most_recent_requisitions
    result = Requisition.most_recent_requisitions(Requisition.visible_to(current_user))
    render json: {
      data: {
        active: serialize_home_requisition(result[:active]),
        archived: serialize_home_requisition(result[:archived])
      }
    }, status: :ok
  end

  private

  def serialize_home_requisition(requisition)
    return {} if requisition.blank?

    RequisitionSerializer.new(requisition, params: { current_user: current_user })
                         .serializable_hash[:data][:attributes]
  end
end
