class RemovePriceFieldsFromProductDetails < ActiveRecord::Migration[7.0]
  def change
    remove_column :product_details, :unit_price, :decimal, default: 0.0
    remove_column :product_details, :dozen_price, :decimal, default: 0.0
    remove_column :product_details, :box_price, :decimal, default: 0.0
    remove_column :product_details, :currency, :string, default: 'usd'
  end
end
