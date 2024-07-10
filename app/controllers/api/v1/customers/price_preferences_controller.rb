class Api::V1::Customers::PricePreferencesController < ApplicationController
  # GET /api/v1/customers/price_preferences
  def index
    render json: serialize_resource(current_user.customer_price_preference, serializer), status: :ok
  end

  # POST /api/v1/customers/price_preferences
  def create
    @price_preference = Customer::PricePreference.find_or_initialize_by(user: current_user)
    @price_preference.price_types = price_preference_params[:price_types]

    if @price_preference.save
      render json: @price_preference, status: :created
    else
      render json: @price_preference.errors, status: :unprocessable_entity
    end
  end

  private

  def serializer
    Customer::PricePreferenceSerializer
  end

  def price_preference_params
    params.require(:price_preference).permit(price_types: [])
  end
end
