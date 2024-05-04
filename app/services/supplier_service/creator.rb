module SupplierService
  class Creator < Base::Creator
    include CategoryHelper

    def initialize(params, user)
      @current_user = user
      super(params)
    end

    private

    def create_record
      @supplier = build_supplier_with_tags
      @supplier.save!
      create_country_and_address
      add_categories

      @supplier
    end

    def build_supplier_with_tags
      Supplier.new(shop_name: @params[:shop_name], images: @params[:images], user: @current_user).tap do |supplier|
        supplier.tag_list = @params[:tags] unless @params[:tags].blank?
      end
    end

    def create_country_and_address
      country_params = { code: @params[:country_id], name: @params[:country_name] }
      country = CountryService::Creator.call(country_params)
      AddressService::Creator.call(@params, @supplier, country)
    end

    def add_categories
      categories = parse_category_ids(@params[:categories])
      update_categories(@supplier, categories)
    end
  end
end
