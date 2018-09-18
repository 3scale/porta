class RemoveSessionToken < ActiveRecord::Migration
  def up
    remove_column :users, :session_token_expires_at
    remove_column :users, :session_token
  end

  def down
    add_column :users, :session_token, :string
    add_column :users, :session_token_expires_at, :datetime
  end
end
