# frozen_string_literal: true
module RequisitionService
  class Retriever < BaseService::Retriever
    def initialize(scope, filter_params)
      @sort_column = %w[created_at]
      super(scope, filter_params)
    end

    def call
      apply_filters
      apply_date_filter
      apply_sorting
    end

    private

    def apply_date_filter
      return if @params[:date].blank?

      @scope = @scope.where(date: Date.parse(@params[:date]))
    rescue ArgumentError
      @scope = @scope.none
    end

    def apply_sorting
      sort_column = @sort_column.include?(@params[:sort]) ? @params[:sort] : 'created_at'
      sort_direction = @sort_direction.include?(@params[:direction]) ? @params[:direction] : 'desc'

      @scope = @scope.reorder(
        Arel.sql("CASE WHEN archived = TRUE THEN 1 ELSE 0 END ASC, #{sort_column} #{sort_direction.upcase}")
      )
    end
  end
end
