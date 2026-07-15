class Api::V1::SupplierProductDetailsController < ApplicationController
  def bulk_create
    unless current_user.supplier?
      render json: { error: 'Only suppliers can add product variants to a shop' }, status: :forbidden
      return
    end

    supplier = current_user.suppliers.order(:created_at).first
    unless supplier
      render json: { error: 'Supplier profile was not found' }, status: :unprocessable_entity
      return
    end

    result = SupplierProductDetail.transaction do
      selected_params.map do |detail_params|
        create_selection!(supplier, detail_params)
      end
    end

    render json: { data: result }, status: :ok
  rescue ActiveRecord::RecordInvalid => e
    render json: error_response(e.record), status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'One or more product variants were not found' }, status: :not_found
  end

  def destroy_product
    unless current_user.supplier?
      render json: { error: 'Only suppliers can remove products from a shop' }, status: :forbidden
      return
    end

    supplier = current_user.suppliers.order(:created_at).first
    unless supplier
      render json: { error: 'Supplier profile was not found' }, status: :unprocessable_entity
      return
    end

    product = Product.supplier_shop_for(current_user).find(params[:product_id])
    product_detail_ids = product.product_details.select(:id)

    SupplierProductDetail.where(supplier: supplier, product_detail_id: product_detail_ids).delete_all
    PriceDetail.where(supplier: supplier, product_detail_id: product_detail_ids).delete_all

    render json: { data: { product_id: product.id, removed: true } }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Product was not found in your shop' }, status: :not_found
  end

  def destroy_product_detail
    unless current_user.supplier?
      render json: { error: 'Only suppliers can remove product variants from a shop' }, status: :forbidden
      return
    end

    supplier = current_user.suppliers.order(:created_at).first
    unless supplier
      render json: { error: 'Supplier profile was not found' }, status: :unprocessable_entity
      return
    end

    product_detail = ProductDetail.supplier_shop_for(current_user).find(params[:product_detail_id])

    SupplierProductDetail.where(supplier: supplier, product_detail: product_detail).delete_all
    PriceDetail.where(supplier: supplier, product_detail: product_detail).delete_all

    render json: { data: { product_detail_id: product_detail.id, removed: true } }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Product variant was not found in your shop' }, status: :not_found
  end

  private

  def selected_params
    details = params.require(:shop_selection).fetch(:product_details, [])
    details = details.values if details.respond_to?(:values)

    details.map do |detail_params|
      ActionController::Parameters
        .new(detail_params.respond_to?(:to_unsafe_h) ? detail_params.to_unsafe_h : detail_params.to_h)
        .permit(:product_detail_id, :currency, :supplier_status, prices: %i[box dozen unit])
        .to_h
        .with_indifferent_access
    end
  end

  def create_selection!(supplier, detail_params)
    product_detail = ProductDetail.visible_to(current_user).find(detail_params[:product_detail_id])
    supplier_status = detail_params.key?(:supplier_status) ? detail_params[:supplier_status] : true

    selection = SupplierProductDetail.find_or_initialize_by(
      supplier: supplier,
      product_detail: product_detail
    )
    selection.supplier_status = ActiveModel::Type::Boolean.new.cast(supplier_status)
    selection.save!

    prices = detail_params.fetch(:prices, {}).to_h.compact_blank
    PriceDetail.custom_upsert(
      prices,
      detail_params[:currency].presence || current_user.default_currency,
      supplier.id,
      product_detail.id,
      selection.supplier_status
    ) if prices.any?

    {
      product_detail_id: product_detail.id,
      supplier_status: selection.supplier_status,
      prices_count: prices.count
    }
  end
end
