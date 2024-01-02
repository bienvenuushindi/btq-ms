class AddDefaultValuesToProductDetailsPrices < ActiveRecord::Migration[7.0]
  def change
    change_column_default :product_details, :unit_price, 0.0
    change_column_default :product_details, :dozen_price, 0.0
    change_column_default :product_details, :box_price, 0.0
  end
end