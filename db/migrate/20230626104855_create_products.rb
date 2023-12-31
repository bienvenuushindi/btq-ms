class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name, null: false , unique: true
      t.text :short_description, default: "Short Description"
      t.text :description, null: true
      t.boolean :active, default: false
      t.string :country_origin
      t.timestamps
    end

    add_index :products, :name
  end
end
