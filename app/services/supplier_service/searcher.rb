# frozen_string_literal: true
module SupplierService
class Searcher < Base::Searcher

  def initialize(scope, search_params)
    super(scope, search_params)
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
    prod_supplier_ids = ProductDetail.find_by(id: @params[:product_detail_id]).suppliers.pluck(:id)
    @scope.where.not(id: prod_supplier_ids)
  end
end
end