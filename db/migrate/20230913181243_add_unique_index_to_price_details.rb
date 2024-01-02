class AddUniqueIndexToPriceDetails < ActiveRecord::Migration[7.0]
  def change
    add_index :price_details, [:supplier_id, :product_detail_id, :quantity_type], unique: true, name: 'index_unique_price_details'
  end
end
