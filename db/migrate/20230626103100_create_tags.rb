class CreateTags < ActiveRecord::Migration[7.0]
  def change
    create_table :tags do |t|
      t.string :name, null: false, unique: true, default: ""
      t.integer :count_suppliers, default: 0
      t.integer :count_products, default: 0
      t.timestamps
    end

    add_index :tags, :name
  end
end
