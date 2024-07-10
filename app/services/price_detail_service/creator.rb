# frozen_string_literal: true
module PriceDetailService
  class Creator < BaseService::Creator
    def initialize(params)
      super(params)
    end

    private

    def create_record
      prices_hash = @params[:prices].to_h
      PriceDetail.custom_upsert(prices_hash, @params[:currency], @params[:supplier_id], @params[:product_detail_id])
    end

  end
end
