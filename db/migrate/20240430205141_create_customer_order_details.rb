class CreateCustomerOrderDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_order_details do |t|
      t.references :customer_individual_order, null: false, foreign_key: true
      t.references :product_detail, null: false, foreign_key: true
      t.references :customer_combined_order, null: false, foreign_key: true
      t.integer :quantity, default: 0
      t.string :quantity_type, limit: 25

      t.timestamps
    end
  end
end
