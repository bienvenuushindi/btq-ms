class Api::V1::Customers::RatingsController < ApplicationController
  def create
    @rating = Rating.new(rating_params)
    if @rating.save
      @product_detail = @rating.product_detail
      @product_detail.calculate_popularity_score
      redirect_to @product_detail, notice: 'Rating was successfully submitted.'
    else
      render :new
    end
  end
end
