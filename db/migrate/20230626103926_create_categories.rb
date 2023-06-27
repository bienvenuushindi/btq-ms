class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false, unique: true, default: ""
      t.string :description, default: "Description"
      t.boolean :active, default: false
      t.integer :count_products, default: 0
      t.integer :parent_category_id, index: true, default: nil
      t.timestamps
    end
  end
end
