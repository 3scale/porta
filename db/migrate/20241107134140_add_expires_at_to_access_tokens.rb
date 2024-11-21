class AddExpiresAtToAccessTokens < ActiveRecord::Migration[6.1]
  disable_ddl_transaction! if System::Database.postgres?

  def change
    add_column :access_tokens, :expires_at, :datetime
  end
end
