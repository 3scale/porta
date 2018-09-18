class AddLostPasswordTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :lost_password_token, :string
  end

  def self.down
    remove_column :users, :lost_password_token
  end
end
