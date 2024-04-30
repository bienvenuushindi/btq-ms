class CreateCustomerCombinedOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_combined_orders do |t|
      t.references :product_detail, null: false, foreign_key: true
      t.string :status, limit: 25
      t.decimal :quantity, precision: 8, scale: 2
      t.string :quantity_type, limit: 25
      t.decimal :total_amount, precision: 8, scale: 2

      t.timestamps
    end
  end
end
