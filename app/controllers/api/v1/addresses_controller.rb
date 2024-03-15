class Api::V1::AddressesController < ApplicationController
  before_action -> { find_record(Address) }, only: %i[show]

  def index
    render json: serialize_resources(Address.all, serializer), status: :ok
  end

  def create
    @address = Address.new(address_params)
    if address.save
      render json: serialize_resource(@address, serializer), status: :created
    else
      render json: error_response(@address)
    end
  end

  def show
    render json: serialize_resource(@address, serializer), status: :ok
  end

  private

  def address_params
    params.require(:address).permit(:line1, :line2, :city, :phone_number1, :phone_number2, :country_id)
  end

  def serializer
    AddressSerializer
  end
end
