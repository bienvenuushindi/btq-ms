# frozen_string_literal: true
module ProductDetailService
  class Creator < BaseService::Creator
    def initialize(params)
      super(params)
    end

    def call
      create_record
    end

    private

    def create_record
      @product_detail = build_product_details
      @product_detail.save!
      @product_detail
    end

    private

    def build_product_details
      ProductDetail.new(size: @params[:size],
                        expired_date: @params[:expired_date],
                        unit_price: @params[:unit_price],
                        dozen_price: @params[:dozen_price],
                        box_price: @params[:box_price],
                        dozen_units: @params[:dozen_units],
                        box_units: @params[:box_units],
                        product: ProductService::Reader.call(@params[:product_id]),
                        status: @params[:status],
                        images: @params[:images]
      ).tap { |product_detail| product_detail.tag_list = @params[:tags] unless @params[:tags].blank? }
    end
  end
end
