class AddStatusToProductDetail < ActiveRecord::Migration[7.0]
  def change
    add_column :product_details, :status, :boolean, default: false
    add_column :product_details, :currency, :string, default: 'usd'
  end
end
