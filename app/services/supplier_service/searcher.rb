# frozen_string_literal: true
module SupplierService
class Searcher < BaseService::Searcher

  def initialize(scope, search_params)
    super(scope, search_params)
    @sort_column = 'shop_name'
    @sort_direction = 'asc'
  end

  protected
  def search
    return  unless @params[:q].present?
    apply_search
    apply_filters
    apply_sorting
    @scope
  end

  private

  def apply_filters
    return unless @params[:product_detail_id].present?

    seller_ids = PriceDetail.supplier_active
                            .where(product_detail_id: @params[:product_detail_id])
                            .select(:supplier_id)

    @scope = if ActiveModel::Type::Boolean.new.cast(@params[:selling])
               @scope.where(id: seller_ids)
             else
               @scope.where.not(id: seller_ids)
             end
  end
end
end
