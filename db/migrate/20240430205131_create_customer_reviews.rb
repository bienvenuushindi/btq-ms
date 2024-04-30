class CreateCustomerReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :rating, scale: 1, default: 0.0
      t.string :comment
      t.references :product_detail, null: false, foreign_key: true

      t.timestamps
    end
  end
end
