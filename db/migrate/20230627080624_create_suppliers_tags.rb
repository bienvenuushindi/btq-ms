class CreateSuppliersTags < ActiveRecord::Migration[7.0]
  def change
    create_table :suppliers_tags do |t|
      t.references :tag, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true

      t.timestamps
    end
  end
end
