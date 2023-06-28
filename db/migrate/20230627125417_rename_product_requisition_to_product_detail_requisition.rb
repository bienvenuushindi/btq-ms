class RenameProductRequisitionToProductDetailRequisition < ActiveRecord::Migration[7.0]
  def change
    rename_table :products_requisitions, :product_details_requisitions
  end
end
