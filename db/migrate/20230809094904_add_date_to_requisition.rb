class AddDateToRequisition < ActiveRecord::Migration[7.0]
  def change
    add_column :requisitions, :date, :date, default: Date.today
  end
end
