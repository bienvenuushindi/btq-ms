class CreateSuppliers < ActiveRecord::Migration[7.0]
  def change
    create_table :suppliers do |t|
      t.string :shop_name
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
