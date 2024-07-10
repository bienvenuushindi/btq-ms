# frozen_string_literal: true
module Customer
  module PreferenceService
    class Retriever < BaseService::Retriever
      def initialize(scope, filter_params)
        @sort_column = %w[created_at]
        super(scope, filter_params)
      end

      def call
        @scope
      end
    end
  end
end