class CreateCustomerPayments < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_payments do |t|
      t.references :customer_individual_order, null: false, foreign_key: true
      t.decimal :amount_paid, default: 0
      t.string :method
      t.string :status, limit: 25

      t.timestamps
    end
  end
end
