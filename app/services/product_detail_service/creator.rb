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
      uploaded_blobs = []
      @product_detail = build_product_details
      @product_detail.validate!
      uploaded_blobs = upload_images!

      ProductDetail.transaction do
        @product_detail.save!
        @product_detail.images.attach(uploaded_blobs) if uploaded_blobs.any?
      end

      @product_detail
    rescue StandardError
      purge_blobs(uploaded_blobs)
      raise
    end

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
                        reviewed_at: (@current_user&.admin? ? Time.current : nil)
      ).tap { |product_detail| product_detail.tag_list = @params[:tags] unless @params[:tags].blank? }
    end

    def upload_images!
      blobs = []
      Array(@params[:images]).each do |image|
        blob = ActiveStorage::Blob.create_after_unfurling!(
          io: image.tempfile,
          filename: image.original_filename,
          content_type: image.content_type
        )
        blob.upload_without_unfurling(image.tempfile)
        blobs << blob
      end
      blobs
    rescue StandardError
      purge_blobs(blobs + [blob].compact)
      raise
    end

    def purge_blobs(blobs)
      blobs.each do |blob|
        blob.purge
      rescue StandardError => error
        Rails.logger.warn("Unable to purge failed product-detail upload #{blob.id}: #{error.message}")
        blob.destroy
      end
    end

    def approval_status
      @current_user&.admin? ? :approved : :pending_review
    end
  end
end
