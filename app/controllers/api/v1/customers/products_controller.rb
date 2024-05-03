class Api::V1::Customers::ProductsController < ApplicationController

  def products

  end

  private

  def product_serializer
    ProductSerializer
  end
end
