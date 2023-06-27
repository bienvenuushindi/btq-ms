class CreateProductDetailsSuppliers < ActiveRecord::Migration[7.0]
  def change
    create_table :product_details_suppliers do |t|
      t.references :product_detail, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true

      t.timestamps
    end
  end
end
