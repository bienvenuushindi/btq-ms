class CreatePriceDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :price_details do |t|
      t.decimal :dozen, null: false
      t.decimal :box
      t.string :currency
      t.references :supplier, null: false, foreign_key: true
      t.references :product_detail, null: false, foreign_key: true
      t.timestamps
    end
  end
end
