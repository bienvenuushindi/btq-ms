class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.string :line1, null: false
      t.string :line2, default: ""
      t.string :city, null: false
      t.string :phone_number1, default: ""
      t.string :phone_number2, default: ""
      t.belongs_to :country, null: false, foreign_key: true
      t.references :addressable, polymorphic: true, null: false
      t.timestamps
    end
  end
end
