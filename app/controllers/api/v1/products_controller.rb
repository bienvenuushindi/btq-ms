class Api::V1::ProductsController < ApplicationController
  before_action :find_product, only: %i[show update]

  def index
    @products = ProductService::Retriever.call(product_scope, product_filter_params)
    render_collection(paginate(@products), serializer, serializer_options)
  end

  def search
    @products = ProductService::Searcher.call(product_scope, product_filter_params)
    render_collection(paginate(@products), serializer, ProductService::Helper.search_options.deep_merge(serializer_options))
  end

  def market
    unless current_user.supplier?
      render json: { error: 'Only suppliers can add products from the market' }, status: :forbidden
      return
    end

    @products = ProductService::Retriever.call(Product.market_for(current_user), params.except(:status, :scope))
    render_collection(paginate(@products), serializer, market_serializer_options)
  end

  def market_search
    unless current_user.supplier?
      render json: { error: 'Only suppliers can search products from the market' }, status: :forbidden
      return
    end

    @products = ProductService::Searcher.call(Product.market_for(current_user), params.except(:status, :scope))
    render_collection(paginate(@products), serializer, ProductService::Helper.search_options.deep_merge(market_serializer_options))
  end

  def count_by_status
    counts = ProductService::StatusCounter.call(current_user)
    render json: { data: counts }, status: :ok
  end

  def create
    @product = ProductService::Creator.call(product_params, current_user)
    render_serialized_resource(@product, serializer, :created )
  end

  def show
    render json: serialize_resource(@product, serializer, product_show_serializer_options), status: :ok
  end

  def update
    if ProductService::Updater.call(@product, product_params, current_user)
      render json: serialize_resource(@product, serializer, serializer_options), status: :ok
    else
      render json: error_response(@product, 'Failed to update the product'), status: :unprocessable_entity
    end
  end

  private

  def find_product
    @product = product_scope.find(params[:id])
  end

  def product_scope
    scope = current_user.supplier? ? Product.supplier_shop_for(current_user) : Product.visible_to(current_user)

    current_user.supplier? ? apply_supplier_status_filter(scope) : scope
  end

  def apply_supplier_status_filter(scope)
    case params[:status].to_s
    when 'true', 'active'
      active_product_ids = PriceDetail
        .joins(:product_detail)
        .supplier_active
        .where(supplier_id: current_user.suppliers.select(:id))
        .select('DISTINCT product_details.product_id')

      submitted_without_prices = scope
        .where(submitted_by_id: current_user.id)
        .where.not(id: PriceDetail.joins(:product_detail).select('DISTINCT product_details.product_id'))

      scope.where(id: active_product_ids).or(submitted_without_prices)
    when 'false', 'inactive'
      active_product_ids = PriceDetail
        .joins(:product_detail)
        .supplier_active
        .where(supplier_id: current_user.suppliers.select(:id))
        .select('DISTINCT product_details.product_id')
      inactive_product_ids = PriceDetail
        .joins(:product_detail)
        .supplier_inactive
        .where(supplier_id: current_user.suppliers.select(:id))
        .select('DISTINCT product_details.product_id')

      scope.where(id: inactive_product_ids).where.not(id: active_product_ids)
    else
      scope
    end
  end

  def product_filter_params
    current_user.supplier? ? params.except(:status, :scope) : params
  end

  def serializer
    ProductSerializer
  end

  def serializer_options
    { params: { current_user: current_user } }
  end

  def market_serializer_options
    serializer_options.deep_merge(params: { market_for_supplier: true })
  end

  def product_show_serializer_options
    serializer_options.deep_merge(params: { include_available_details: true })
  end

  def product_params
    ProductService::Helper.product_params(params)
  end
end
