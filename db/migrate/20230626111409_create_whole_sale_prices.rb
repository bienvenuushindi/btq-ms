class CreateWholeSalePrices < ActiveRecord::Migration[7.0]
  def change
    create_table :whole_sale_prices do |t|
      t.decimal :dozen
      t.decimal :box
      t.string :currency

      t.timestamps
    end
  end
end
