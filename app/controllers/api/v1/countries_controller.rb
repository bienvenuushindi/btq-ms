class Api::V1::CountriesController < ApplicationController
  before_action :set_country, only: %i[show]

  def index
    data =  serializer.new(Country.all)
    render json: data, status: :ok
  end

  def create
    country = Country.new(country_params)
    if country.save
      render json: serializer.new(country), status: :created
    else
      render json: error_response(country)
    end
  end

  def show
    render json: serializer.new(set_country), status: :ok
  end

  private

  def serializer
    CountrySerializer
  end

  def set_country
    Country.find(params[:id])
  end

  def country_params
    params.require(:country).permit(:name, :code)
  end
end
