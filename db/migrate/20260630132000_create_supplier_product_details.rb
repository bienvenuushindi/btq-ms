class CreateSupplierProductDetails < ActiveRecord::Migration[7.0]
  def up
    create_table :supplier_product_details do |t|
      t.references :supplier, null: false, foreign_key: true
      t.references :product_detail, null: false, foreign_key: true
      t.boolean :supplier_status, null: false, default: true

      t.timestamps
    end

    add_index :supplier_product_details,
              %i[supplier_id product_detail_id],
              unique: true,
              name: 'index_supplier_product_details_on_supplier_and_detail'

    execute <<~SQL.squish
      INSERT INTO supplier_product_details (
        supplier_id,
        product_detail_id,
        supplier_status,
        created_at,
        updated_at
      )
      SELECT
        supplier_id,
        product_detail_id,
        BOOL_OR(supplier_status),
        NOW(),
        NOW()
      FROM price_details
      GROUP BY supplier_id, product_detail_id
      ON CONFLICT (supplier_id, product_detail_id) DO NOTHING
    SQL
  end

  def down
    drop_table :supplier_product_details
  end
end
