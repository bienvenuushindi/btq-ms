# frozen_string_literal: true
module PriceDetailService
  class Creator < BaseService::Creator
    def initialize(params)
      super(params)
    end

    private

    def create_record
      prices_hash = @params[:prices].to_h.compact_blank
      raise ActiveRecord::RecordInvalid.new(invalid_price_detail) if prices_hash.empty?

      PriceDetail.custom_upsert(prices_hash, @params[:currency], @params[:supplier_id], @params[:product_detail_id])
    end

    def invalid_price_detail
      PriceDetail.new.tap do |price_detail|
        price_detail.errors.add(:base, 'Select at least one pricing size and enter a price before saving the supplier')
      end
    end

  end
end
