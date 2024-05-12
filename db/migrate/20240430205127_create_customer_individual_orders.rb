class CreateCustomerIndividualOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_individual_orders do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :total_amount, default: 0
      t.string :status, limit: 25
      t.date :delivery_date

      t.timestamps
    end
  end
end
