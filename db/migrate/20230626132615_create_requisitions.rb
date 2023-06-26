class CreateRequisitions < ActiveRecord::Migration[7.0]
  def change
    create_table :requisitions do |t|
      t.date :date
      t.decimal :total
      t.integer :count_products
      t.integer :count_prodcuts_bought
      t.string :price_currency

      t.timestamps
    end
  end
end
