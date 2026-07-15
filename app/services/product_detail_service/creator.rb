# frozen_string_literal: true
module ProductDetailService
  class Creator < BaseService::Creator
    def initialize(params, current_user = nil)
      @current_user = current_user
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
                        dozen_units: @params[:dozen_units],
                        box_units: @params[:box_units],
                        product: ProductService::Reader.call(@params[:product_id]),
                        approval_status: approval_status,
                        status: @current_user&.admin?,
                        submitted_by: @current_user,
                        reviewed_by: (@current_user if @current_user&.admin?),
                        reviewed_at: (@current_user&.admin? ? Time.current : nil),
                        images: @params[:images]
      ).tap { |product_detail| product_detail.tag_list = @params[:tags] unless @params[:tags].blank? }
    end

    def approval_status
      @current_user&.admin? ? :approved : :pending_review
    end
  end
end
