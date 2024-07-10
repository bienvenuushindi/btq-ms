class Api::V1::Customers::PreferencesController < ApplicationController
  include CategoryHelper
  def create
    category_ids = parse_category_ids(preferences_params[:category_ids])
    existing_category_ids = current_user.customer_preferences.pluck(:category_id)

    # Find preferences to be destroyed
    preferences_to_destroy = existing_category_ids - category_ids
    # Find new preferences to be created
    preferences_to_create = category_ids - existing_category_ids

    # Destroy preferences that are no longer selected
    current_user.customer_preferences.where(category_id: preferences_to_destroy).destroy_all

    # Create preferences for newly selected categories
    preferences_to_create.each do |category_id|
      current_user.customer_preferences.create(category_id: category_id)
    end

    render json: { message: 'Preferences successfully updated' }, status: :ok
  end

  private

  def serializer
    Customer::PreferenceSerializer
  end

  def preferences_params
    params.require(:preferences).permit(category_ids: [])
  end
end
