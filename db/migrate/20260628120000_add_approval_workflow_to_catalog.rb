class AddApprovalWorkflowToCatalog < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :approval_status, :integer, default: 0, null: false
    add_reference :products, :submitted_by, foreign_key: { to_table: :users }
    add_reference :products, :reviewed_by, foreign_key: { to_table: :users }
    add_column :products, :reviewed_at, :datetime
    add_column :products, :rejection_reason, :text

    add_column :product_details, :approval_status, :integer, default: 0, null: false
    add_reference :product_details, :submitted_by, foreign_key: { to_table: :users }
    add_reference :product_details, :reviewed_by, foreign_key: { to_table: :users }
    add_column :product_details, :reviewed_at, :datetime
    add_column :product_details, :rejection_reason, :text

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE products
          SET approval_status = CASE WHEN active = TRUE THEN 1 ELSE 0 END,
              submitted_by_id = user_id
        SQL

        execute <<~SQL.squish
          UPDATE product_details
          SET approval_status = CASE WHEN status = TRUE THEN 1 ELSE 0 END
        SQL
      end
    end

    add_index :products, :approval_status
    add_index :product_details, :approval_status
  end
end
