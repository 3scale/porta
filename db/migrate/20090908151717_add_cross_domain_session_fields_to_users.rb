class AddCrossDomainSessionFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :session_token, :string
    add_column :users, :session_token_expires_at, :datetime
  end

  def self.down
    remove_column :users, :session_token_expires_at
    remove_column :users, :session_token
  end
end
