class CreateCustomerPayments < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_payments do |t|
      t.references :individual_order, null: false, foreign_key: true
      t.decimal :amount_paid,  scale: 2, default: 0.0
      t.string :method
      t.string :status, limit: 25

      t.timestamps
    end
  end
end
