class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :short_description
      t.string :description
      t.boolean :active
      t.string :country_origin

      t.timestamps
    end
  end
end
