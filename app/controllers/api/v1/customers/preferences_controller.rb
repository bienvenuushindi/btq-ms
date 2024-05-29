class Api::V1::Customers::PreferencesController < ApplicationController
  def index
    render json: serialize_resources(Customer::Preference.all, serializer), status: :ok
  end

  def create
    category_ids = preferences_params[:category_ids] # Assuming category_ids is an array of selected category IDs

    # Create preferences for each selected category
    category_ids.each do |category_id|
      current_user.customer_preferences.create(category_id: category_id)
    end
    render json: { message: 'Preferences successfully created' }, status: :created
  end

  private

  def serializer
    Customer::PreferenceSerializer
  end

  def preferences_params
    params.require(:preferences).permit(category_ids: [])
  end
end
