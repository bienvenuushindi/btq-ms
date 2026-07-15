# frozen_string_literal: true
module ProductService
class Searcher < BaseService::Searcher
  def initialize(scope, search_params)
    super(scope, search_params)
  end

  protected
  def search
    return  unless @params[:q].present?
    apply_search
    apply_category_filter
    apply_sorting
    @scope
  end

  private

  def apply_category_filter
    category_ids = Array(@params[:category_ids].presence || @params[:category_id]).compact_blank
    return if category_ids.empty?

    product_ids = Product.joins(:categories).where(categories: { id: category_ids }).select(:id)
    @scope = @scope.where(id: product_ids)
  end
end
end
