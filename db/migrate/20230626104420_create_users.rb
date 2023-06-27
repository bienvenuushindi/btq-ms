class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :phone_number, null: false, unique: true
      t.references :role,  null: false, foreign_key: true
      t.timestamps
    end
  end
end