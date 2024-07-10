# frozen_string_literal: true
module Customer
  module PreferenceService
    class Creator < BaseService::Creator
      def initialize(params)
        super(params)
      end

      private

      def create_record
        @category = build_category
        @category.save!

        @category
      end

      private

      def build_category
        Category.new(
          name: @params[:name],
          description: @params[:description],
          active: @params[:active],
          parent_category_id: @params[:parent_category_id]&.presence
        )
      end
    end
  end
end
