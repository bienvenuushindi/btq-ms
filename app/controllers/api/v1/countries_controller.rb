class Api::V1::CountriesController < ApplicationController
  before_action :set_country, only: %i[show]

  def index
    render json: fetch_response(Country.all), status: :ok
  end

  def create
    country = Country.new(country_params)
    if country.save
      render json: created_response(country), status: :created
    else
      render json: error_response(country)
    end
  end

  def show
    render json: fetch_response(set_country), status: :ok
  end

  private

  def set_country
    Country.find(params[:id])
  end

  def country_params
    params.require(:country).permit(:name, :code)
  end
end
