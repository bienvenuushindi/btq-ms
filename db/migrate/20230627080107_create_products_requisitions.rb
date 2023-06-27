class CreateProductsRequisitions < ActiveRecord::Migration[7.0]
  def change
    create_table :products_requisitions do |t|
      t.boolean :found, default: false
      t.integer :quantity, default: 0
      t.integer :quantity_type # this will be defined as enum type in the related model {unit,dozen,box}
      t.date :expired_date
      t.decimal :price
      t.string :currency
      t.references :requisition, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true
      t.timestamps
    end
  end
end
