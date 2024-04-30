class AddNullValueToCategories < ActiveRecord::Migration[7.0]
  def change
    change_column_null :categories , :parent_category_id, true
  end
end
