class RemoveProductFromProductDetailsRequisitions < ActiveRecord::Migration[7.0]
  def change
    remove_column :product_details_requisitions, :product_id, index:true, foreign_key: true
  end
end
