class CreateCustomerPricePreferences < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_price_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.string :price_types, array: true, default: []

      t.timestamps
    end
  end
end
