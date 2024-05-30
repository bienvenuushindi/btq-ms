class AddPreferenceCountToCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :preference_count, :integer, default: 0
  end
end
