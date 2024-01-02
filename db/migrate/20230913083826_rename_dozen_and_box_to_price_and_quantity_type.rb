class RenameDozenAndBoxToPriceAndQuantityType < ActiveRecord::Migration[7.0]
  def change
    change_column :price_details, :box, :integer
    rename_column :price_details, :dozen, :price
    rename_column :price_details, :box, :quantity_type
  end
end
