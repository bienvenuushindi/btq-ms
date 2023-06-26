class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.string :line1
      t.string :line2
      t.string :city
      t.string :phone_number1
      t.string :phone_number2
      t.string :phone_number3

      t.timestamps
    end
  end
end
