class AddSalesCountAndViewsToProductDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :product_details, :sales_count, :integer, default: 0
    add_column :product_details, :views, :integer, default: 0
  end
end
