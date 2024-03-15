class RenameFoundToStatus < ActiveRecord::Migration[7.0]
  def change
    # First, remove any default value from the "found" column
    change_column_default :product_details_requisitions, :found, nil
    
    # Then, change the data type of the "found" column to integer using a SQL command
    execute <<-SQL
      ALTER TABLE product_details_requisitions
      ALTER COLUMN found TYPE integer
      USING CASE WHEN found = 'true' THEN 1 ELSE 0 END
    SQL
    
    # Finally, rename the column to "status"
    rename_column :product_details_requisitions, :found, :status
  end
end
