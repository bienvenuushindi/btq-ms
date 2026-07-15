# frozen_string_literal: true
module ProductService
  class Creator < BaseService::Creator
    include CategoryHelper

    def initialize(params, user)
      @current_user = user
      super(params)
    end

    private

    def create_record
      @product = build_product_with_tags
      @product.save!
      add_categories

      @product
    end

    def build_product_with_tags
      @product = Product.new(
        user: @current_user,
        name: @params[:name],
        short_description: @params[:short_description],
        description: @params[:description],
        approval_status: approval_status,
        active: @current_user.admin?,
        catalog_scope: catalog_scope,
        country_origin: @params[:country_origin],
        submitted_by: @current_user,
        reviewed_by: (@current_user if @current_user.admin?),
        reviewed_at: (@current_user.admin? ? Time.current : nil),
        images: @params[:images]
      ).tap { |product| product.tag_list = @params[:tags] unless @params[:tags].blank? }
    end

    def approval_status
      @current_user.admin? ? :approved : :pending_review
    end

    def catalog_scope
      Product.catalog_scopes.key?(@params[:catalog_scope].to_s) ? @params[:catalog_scope] : :public_catalog
    end

    def add_categories
      categories = parse_category_ids(@params[:categories])
      update_categories(@product, categories)
    end
  end
end
