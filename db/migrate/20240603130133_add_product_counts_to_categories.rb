class AddProductCountsToCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :inactive_count_products, :integer, default: 0
  end
end
