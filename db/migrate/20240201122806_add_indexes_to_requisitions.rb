class AddIndexesToRequisitions < ActiveRecord::Migration[7.0]
  def change
    add_index :requisitions, [:archived, :created_at]
  end
end
