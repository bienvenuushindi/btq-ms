class CreateCustomerShippings < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_shippings do |t|
      t.references :customer_individual_order, null: false, foreign_key: true
      t.references :address, null: false, foreign_key: true
      t.timestamps
    end
  end
end
