# frozen_string_literal: true

class AddExpiredDateToSupplierProductDetails < ActiveRecord::Migration[7.0]
  def up
    add_column :supplier_product_details, :expired_date, :date
    execute <<~SQL.squish
      UPDATE supplier_product_details
      SET expired_date = COALESCE(product_details.expired_date, CURRENT_DATE)
      FROM product_details
      WHERE supplier_product_details.product_detail_id = product_details.id
    SQL
    change_column_null :supplier_product_details, :expired_date, false
    add_index :supplier_product_details, :expired_date
  end

  def down
    remove_index :supplier_product_details, :expired_date
    remove_column :supplier_product_details, :expired_date
  end
end
