class AddPopularityScoreToProductDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :product_details, :popularity_score, :decimal, default: 0.0, null: true
  end
end
