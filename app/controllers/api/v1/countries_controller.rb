class Api::V1::CountriesController < ApplicationController
  before_action :find_country, only: %i[show]

  def index
    @countries = CountryService::Retriever.call(Country.all, params)
    render_collection(paginate(@countries), serializer)
  end

  def create
    @country = CountryService::Creator.call(country_params)
    render_serialized_resource(@country, serializer, :created)
  end

  def show
    render json: serialize_resource(@country, serializer), status: :ok
  end

  private

  def serializer
    CountrySerializer
  end

  def country_params
    CountryService::Helper.country_params(params)
  end

  def find_country
    @country =  CountryService::Reader.call(params[:id])
  end
end
