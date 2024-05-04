# frozen_string_literal: true
module ProductService
class Searcher < Base::Searcher
  def initialize(scope, search_params)
    super(scope, search_params)
  end

  protected
  def search
    return  unless @params[:q].present?
    apply_search
    apply_sorting
    @scope
  end
end
end