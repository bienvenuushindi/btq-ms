class CreateWholeSalePrices < ActiveRecord::Migration[7.0]
  def change
    create_table :whole_sale_prices do |t|
      t.decimal :dozen, null: false
      t.decimal :box
      t.string :currency
      t.references :country, null: false, foreign_key: true
      t.references :supplier, null:false , foreign_key:true
      t.timestamps
    end
  end
end
