module SupplierService
  class Creator < BaseService::Creator
    include CategoryHelper

    DEFAULT_PASSWORD = ENV.fetch('DEFAULT_SUPPLIER_PASSWORD', 'Supplier@123').freeze

    def initialize(params, _admin)
      super(params)
    end

    def call
      create_record
    rescue ActiveRecord::RecordInvalid => e
      supplier = Supplier.new
      e.record.errors.full_messages.each { |message| supplier.errors.add(:base, message) }
      supplier
    end

    private

    def create_record
      Supplier.transaction do
        @supplier_user = create_supplier_user!
        @supplier = build_supplier_with_tags
        @supplier.temporary_password = DEFAULT_PASSWORD
        @supplier.save!
        create_country_and_address
        add_categories(@supplier, @params)
      end

      @supplier
    end

    def create_supplier_user!
      role = Role.find_by('LOWER(name) = ?', 'supplier')
      raise ActiveRecord::RecordNotFound, 'Supplier role is not configured' unless role

      User.create!(
        name: @params[:name],
        email: @params[:email],
        phone_number: @params[:phone_number].presence || @params[:tel1],
        role: role,
        must_change_password: true,
        password: DEFAULT_PASSWORD,
        password_confirmation: DEFAULT_PASSWORD
      )
    end

    def build_supplier_with_tags
      Supplier.new(shop_name: @params[:shop_name], images: @params[:images], user: @supplier_user).tap do |supplier|
        supplier.tag_list = @params[:tags] unless @params[:tags].blank?
      end
    end

    def create_country_and_address
      country_params = { code: @params[:country_id], name: @params[:country_name] }
      country = CountryService::Creator.call(country_params)
      AddressService::Creator.call(@params, @supplier, country)
    end
  end
end
