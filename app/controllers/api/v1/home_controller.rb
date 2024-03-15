class Api::V1::HomeController < ApplicationController

  def most_recent_requisitions
    result = Requisition.most_recent_requisitions
    render json: { data: { active: result[:active], archived: result[:archived] } }, status: :ok
  end
end
