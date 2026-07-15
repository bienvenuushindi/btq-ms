class AddCatalogScopeAndSupplierStatus < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :catalog_scope, :integer, default: 0, null: false
    add_column :price_details, :supplier_status, :boolean, default: true, null: false

    add_index :products, :catalog_scope
    add_index :price_details, :supplier_status
  end
end
