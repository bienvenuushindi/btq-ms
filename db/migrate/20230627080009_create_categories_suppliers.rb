class CreateCategoriesSuppliers < ActiveRecord::Migration[7.0]
  def change
    create_table :categories_suppliers do |t|
      t.references :category, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true

      t.timestamps
    end
  end
end
