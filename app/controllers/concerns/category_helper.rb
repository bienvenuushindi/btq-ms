# app/controllers/concerns/category_helper.rb
module CategoryHelper
  extend ActiveSupport::Concern

  included do
    private

    def parse_category_ids(categories_string_or_array)
      if categories_string_or_array.is_a?(Array)
        categories_string_or_array.map(&:to_i)
      elsif categories_string_or_array.is_a?(String)
        categories_string_or_array.split(',').map(&:to_i)
      else
        [] # Return an empty array if the input is neither a string nor an array
      end
    end

    def update_categories(resource, category_ids)
      current_category_ids = resource.category_ids
      new_category_ids = category_ids.map(&:to_i)

      categories_to_add = new_category_ids - current_category_ids
      categories_to_remove = current_category_ids - new_category_ids

      # Add new categories using batch creation
      categorization_attributes = categories_to_add.map { |category_id| { category_id: category_id } }
      resource.categorizations.create(categorization_attributes) if categories_to_add.any?

      # Remove existing categories not included in the new list
      resource.categorizations.where(category_id: categories_to_remove).destroy_all if categories_to_remove.any?
    end
  end
end
