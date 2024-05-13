# frozen_string_literal: true
module CountryService
class Retriever < BaseService::Retriever
  def initialize(scope, filter_params)
    @sort_column = %w[name code]
    super(scope, filter_params)
  end


  def call
    apply_filters
    apply_sorting
  end
end
end