class AddProductToProductDetail < ActiveRecord::Migration[7.0]
  def change
    add_reference :product_details, :product, null: false, foreign_key: true
  end
end
