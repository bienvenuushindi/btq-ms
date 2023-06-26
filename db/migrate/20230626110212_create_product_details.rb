class CreateProductDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :product_details do |t|
      t.string :size
      t.date :expired_date
      t.decimal :unit_price
      t.decimal :dozen_price
      t.decimal :box_price
      t.integer :dozen_units
      t.integer :box_units

      t.timestamps
    end
  end
end
