# frozen_string_literal: true
module Base
  class Searcher < ApplicationService
    def initialize(scope, search_params)
      @scope = scope
      @params = search_params
      @sort_column = 'created_at'
      @sort_direction = 'desc'
    end

    def call
      search
    end

    protected

    def search
      raise NotImplementedError, "#{self.class} does not implement ##{__method__}"
    end

    def apply_search
      return  unless @params[:q].present?
      @scope = @scope.search(@params[:q])
    end

    def apply_sorting
      @scope.order(@sort_column => @sort_direction)
    end
  end
end