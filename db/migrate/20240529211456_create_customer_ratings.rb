class CreateCustomerRatings < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_ratings do |t|
      t.integer :score
      t.references :user, null: false, foreign_key: true
      t.references :product_detail, null: false, foreign_key: true

      t.timestamps
    end
  end
end
