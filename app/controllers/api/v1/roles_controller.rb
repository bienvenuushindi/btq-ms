class Api::V1::RolesController < ApplicationController
  before_action :set_role, only: %i[show]

  def index
    render json: fetch_response(Role.all), status: :ok
  end

  def create
    role = Role.new(role_params)
    if role.save
      render json: created_response(role), status: :created
    else
      render json: error_response(role)
    end
  end

  def show
    render json: fetch_response(set_role), status: :ok
  end

  private

  def set_role
    Role.find(params[:id])
  end

  def role_params
    params.require(:role).permit(:name)
  end
end
