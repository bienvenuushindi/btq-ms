# frozen_string_literal: true
module BaseService
  class Retriever < ApplicationService
    attr_accessor :sort_column

    def initialize(scope, filter_params)
      @scope = scope
      @params = filter_params
      @sort_direction = %w[asc desc]
    end

    private

    def apply_filters
      @scope = @scope.search(@params[:q]) if @params[:q].present?
      @scope = @scope.by_status(@params[:status]) if @params[:status].present?
      # Add any additional product-specific filtering logic here based on @params
    end

    def apply_sorting
      sort_column = @sort_column.include?(@params[:sort]) ? @params[:sort] : 'created_at'
      sort_direction = @sort_direction.include?(@params[:direction]) ? @params[:direction] : 'desc'
      @scope = @scope.reorder(sort_column => sort_direction)
    end
  end
end