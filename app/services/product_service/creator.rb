# frozen_string_literal: true
module ProductService
  class Creator < Base::Creator
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
        active: @params[:active],
        country_origin: @params[:country_origin],
        images: @params[:images]
      ).tap { |product| product.tag_list = @params[:tags] unless @params[:tags].blank? }
    end

    def add_categories
      categories = parse_category_ids(@params[:categories])
      update_categories(@product, categories)
    end
  end
end
