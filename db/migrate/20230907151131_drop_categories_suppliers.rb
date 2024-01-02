class DropCategoriesSuppliers < ActiveRecord::Migration[7.0]
  def change
    drop_table :categories_suppliers
  end
end
