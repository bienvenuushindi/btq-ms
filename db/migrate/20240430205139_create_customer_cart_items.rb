class CreateCustomerCartItems < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :product_detail, null: false, foreign_key: true
      t.decimal :quantity, precision: 8, scale: 2
      t.string :quantity_type, limit: 25

      t.timestamps
    end
  end
end
