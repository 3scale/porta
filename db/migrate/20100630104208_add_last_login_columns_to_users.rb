class AddLastLoginColumnsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_login_at, :datetime
    add_column :users, :last_login_ip, :string
  end

  def self.down
    remove_column :users, :last_login_ip
    remove_column :users, :last_login_at
  end
end
