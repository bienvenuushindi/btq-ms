class CreateProductsRequisitions < ActiveRecord::Migration[7.0]
  def change
    create_table :products_requisitions do |t|
      t.references :requisition, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
