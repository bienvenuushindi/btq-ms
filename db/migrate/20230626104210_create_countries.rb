class CreateCountries < ActiveRecord::Migration[7.0]
  def change
    create_table :countries do |t|
      t.string :name, null: false, unique: true, default: ""
      t.string :code, null: false, unique: true
      t.timestamps
    end
  end
end
