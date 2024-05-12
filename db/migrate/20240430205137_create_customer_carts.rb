class CreateCustomerCarts < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_carts do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :status
      t.decimal :total_amount, default: 0

      t.timestamps
    end
  end
end
