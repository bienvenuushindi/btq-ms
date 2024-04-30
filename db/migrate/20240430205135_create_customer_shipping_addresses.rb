class CreateCustomerShippingAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_shipping_addresses do |t|
      t.references :individual_order, null: false, foreign_key: true
      t.timestamps
    end
  end
end
