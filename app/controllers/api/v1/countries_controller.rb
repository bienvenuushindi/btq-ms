class Api::V1::CountriesController < ApplicationController
  before_action -> { find_record(Country) }, only: %i[show]

  def index
    data =  serialize_resources(Country.all, serializer)
    render json: data, status: :ok
  end

  def create
    @country = Country.new(country_params)
    if @country.save
      render json: serialize_resource(@country, serializer), status: :created

    else
      render json: error_response(@country)
    end
  end

  def show
    render json: serialize_resource(@country, serializer), status: :ok
  end

  private

  def serializer
    CountrySerializer
  end

  def country_params
    params.require(:country).permit(:name, :code)
  end
end
