class Api::V1::RolesController < ApplicationController
  before_action -> { find_record(Role) }, only: %i[show]

  def index
    render json: serialize_resources(Role.all, serializer), status: :ok
  end

  def create
    @role = Role.new(role_params)
    if @role.save
      render json: serialize_resource(@role, serializer), status: :created
    else
      render json: error_response(@role)
    end
  end

  def show
    render json: serialize_resource(@role, serializer), status: :ok
  end

  private

  def serializer
    RoleSerializer.new()
  end

  def role_params
    params.require(:role).permit(:name)
  end
end
