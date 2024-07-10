class Api::V1::Customers::ProductsController < ApplicationController

  def index
    @categories = fetch_categories

    render_collection(
      paginate(@categories),
      CategorySerializer,
      {
        params: { current_user: current_user, fields: CategorySerializer.fields_with_products },
        fields: { category: CategorySerializer.fields_with_products }
      }
    )
  end

  private

  def fetch_categories
    if params[:categories_ids]
      Category.active.where(id: params[:categories_ids])
    else
      fetch_categories_based_on_preferences
    end
  end

  def fetch_categories_based_on_preferences
    if current_user.customer_preferences.present?
      current_user.categories.active
    else
      Category.active.popular
    end
  end

  def product_serializer
    ProductSerializer
  end
end
