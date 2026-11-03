class AddExpirableToProducts < ActiveRecord::Migration[7.0]
  def up
    add_column :products, :expirable, :boolean, default: true, null: false
    change_column_null :supplier_product_details, :expired_date, true
  end

  def down
    execute <<~SQL
      UPDATE supplier_product_details
      SET expired_date = COALESCE(
        expired_date,
        (SELECT product_details.expired_date
         FROM product_details
         WHERE product_details.id = supplier_product_details.product_detail_id),
        CURRENT_DATE
      )
      WHERE expired_date IS NULL
    SQL
    change_column_null :supplier_product_details, :expired_date, false
    remove_column :products, :expirable
  end
end
