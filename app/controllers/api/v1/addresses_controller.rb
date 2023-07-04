class Api::V1::AddressesController < ApplicationController
  before_action :set_address, only: %i[show]

  def index
    render json: fetch_response(Address.all), status: :ok
  end

  def create
    address = Address.new(address_params)
    if address.save
      render json: created_response(address), status: :created
    else
      render json: error_response(address)
    end
  end

  def show
    render json: fetch_response(set_address), status: :ok
  end

  private

  def set_address
    Address.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:line1, :line2, :city, :phone_number1, :phone_number2, :country_id)
  end
end
