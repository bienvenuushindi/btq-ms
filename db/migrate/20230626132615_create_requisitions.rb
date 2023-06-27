class CreateRequisitions < ActiveRecord::Migration[7.0]
  def change
    create_table :requisitions do |t|
      t.date :date
      t.decimal :total
      t.integer :count_products, default: 0
      t.integer :count_products_bought, default: 0
      t.string :price_currency
      t.references :user, null: true, foreign_key: true
      t.timestamps
    end
  end
end
