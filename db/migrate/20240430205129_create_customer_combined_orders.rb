class CreateCustomerCombinedOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_combined_orders do |t|
      t.references :product_detail, null: false, foreign_key: true
      t.string :status, limit: 25
      t.integer :quantity, default: 0
      t.string :quantity_type, limit: 25
      t.decimal :total_amount, default: 0

      t.timestamps
    end
  end
end
