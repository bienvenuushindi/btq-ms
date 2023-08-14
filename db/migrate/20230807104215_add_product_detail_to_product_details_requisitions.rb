class AddProductDetailToProductDetailsRequisitions < ActiveRecord::Migration[7.0]
  def change
    add_reference :product_details_requisitions, :product_detail, null: false, foreign_key: true
  end
end