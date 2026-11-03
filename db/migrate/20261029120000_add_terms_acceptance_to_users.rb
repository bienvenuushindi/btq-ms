class AddTermsAcceptanceToUsers < ActiveRecord::Migration[7.0]
  TERMS_VERSION = '1.0.0'

  def up
    add_column :users, :terms_accepted_at, :datetime
    add_column :users, :terms_version, :string
    execute <<~SQL
      UPDATE users
      SET terms_accepted_at = CURRENT_TIMESTAMP,
          terms_version = '#{TERMS_VERSION}'
    SQL
  end

  def down
    remove_column :users, :terms_version
    remove_column :users, :terms_accepted_at
  end
end
