# frozen_string_literal: true

class Api::V1::Customers::ClientsController < ApplicationController
  def preferences
    render json: serialize_resources(current_user.customer_preferences, Customer::PreferenceSerializer), status: :ok
  end


end
