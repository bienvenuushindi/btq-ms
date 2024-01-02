class Api::V1::SuppliersController < ApplicationController
  before_action :set_supplier, only: %i[show update]

  def index
    options = {}
    options[:fields] = { supplier: [:id, :shop_name, :image_urls, :address1, :address2, :city, :country, :code, :tel1, :tel2] }
    suppliers = Supplier.all
    suppliers = suppliers.search(params[:q]) if params[:q].present?
    suppliers = suppliers.reorder(sort_column => sort_direction)
    suppliers = suppliers.with_attached_images.order(created_at: :desc)
    paginated = paginate(suppliers)

    suppliers.present? ? render_collection(paginated, options) : :not_found
  end


  def sort_column
    %w{shop_name created_at}.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    %w{asc desc }.include?(params[:direction]) ? params[:direction] : "desc"
  end

  def search
    suppliers = nil
    paginated = nil
    options = {}
    if params[:q].present?
      options[:fields] = { supplier: [:id, :shop_name, :image_urls, :address1, :address2, :city, :country, :code, :tel1, :tel2] }
      suppliers = Supplier.all.search(params[:q]).limit(4)
      if params[:product_detail_id].present?
        prod_supplier_ids = ProductDetail.find_by(id: params[:product_detail_id]).suppliers.pluck(:id)
        # Exclude suppliers in prod_suppliers
        suppliers = suppliers.where.not(id: prod_supplier_ids)
      end
      suppliers = suppliers.order(created_at: :desc)
      paginated = paginate(suppliers)
    end
    suppliers.present? ? render_collection(paginated, options) : :not_found
  end

  def create
    supplier = Supplier.new(shop_name: supplier_params[:shop_name], user: current_user, images: supplier_params[:images])
    supplier.tag_list = supplier_params[:tags] unless supplier_params[:tags].blank?
    if supplier.save
      country = Country.create_with(name: supplier_params[:country_name]).find_or_create_by(code: supplier_params[:country_id])
      Address.create!(line1: supplier_params[:address1],
                      city: supplier_params[:city],
                      country:,
                      phone_number1: supplier_params[:tel1],
                      phone_number2: supplier_params[:tel2],
                      line2: supplier_params[:address2],
                      addressable: supplier)
      render json: serializer.new(supplier), status: :created
    else
      render json: error_response(supplier)
    end
  end

  def show
    options = {}
    supplier = Supplier.find(params[:id])
    options[:fields] = { supplier: [:id, :shop_name, :tags, :image_urls, :address1, :address2, :city, :country, :code, :tel1, :tel2] }
    data = serializer.new(supplier, options)
    render json: data, status: :ok
  end

  def update
    supplier = Supplier.find(params[:id])
    update_supplier_attributes(supplier, supplier_params)
    if supplier.save
      render json: serializer.new(supplier), status: :ok
    else
      render json: error_response(supplier), status: :unprocessable_entity
    end
  end
  
  private
  def update_supplier_attributes(supplier, params)
    update_attribute(supplier, :shop_name, params[:shop_name])
    update_attribute(supplier, :tags, params[:tags])
    update_attribute(supplier, :images, params[:images])
    update_attribute(supplier, :address, params)
  end

  def serializer
    SupplierSerializer
  end

  def set_supplier
    Supplier.find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(:shop_name, :address1, :address2, :city, :tel1, :country_name, :tel2, :country_id, :tags, images: [])
  end
end
