class ChangeNullForSupplierFromProductDetailsRequisitions < ActiveRecord::Migration[7.0]
  def change
    change_column_null :product_details_requisitions, :supplier_id, null: true
    change_column_default :product_details_requisitions, :quantity_type, default: 0
    change_column_default :product_details_requisitions, :expired_date, default: nil
    change_column_default :product_details_requisitions, :price, default: 0
  end
end
