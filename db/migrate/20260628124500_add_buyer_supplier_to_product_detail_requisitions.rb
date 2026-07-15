class AddBuyerSupplierToProductDetailRequisitions < ActiveRecord::Migration[7.0]
  def change
    add_reference :product_details_requisitions, :buyer_supplier, foreign_key: { to_table: :suppliers }

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE product_details_requisitions pdr
          SET buyer_supplier_id = suppliers.id
          FROM requisitions, suppliers
          WHERE pdr.requisition_id = requisitions.id
            AND suppliers.user_id = requisitions.user_id
            AND suppliers.id = (
              SELECT s.id
              FROM suppliers s
              WHERE s.user_id = requisitions.user_id
              ORDER BY s.created_at ASC
              LIMIT 1
            )
        SQL
      end
    end
  end
end
