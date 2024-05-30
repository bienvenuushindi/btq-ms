class Api::V1::Customers::ProductsController < ApplicationController

  def index
    # get the customer category preferences
    # then for each preference select the top product
    # fetch the details
    products = nil
    if params[:categories_ids]
      categories = Category.where(id: params[:categories_ids])
      products = current_user.fetch_data_based_categories(categories)
    else
      products = current_user.fetch_data_based_on_preferences
    end

    render json: products
  end

  private

  def product_serializer
    ProductSerializer
  end
end
