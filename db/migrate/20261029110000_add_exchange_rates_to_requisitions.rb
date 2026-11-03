class AddExchangeRatesToRequisitions < ActiveRecord::Migration[7.0]
  def change
    add_column :requisitions, :exchange_rates, :jsonb, null: false, default: {}
  end
end
