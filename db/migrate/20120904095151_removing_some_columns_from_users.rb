class RemovingSomeColumnsFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :last_seen_at
    remove_column :users, :uncrypted_password
  end

  def self.down
    add_column :users, :last_seen_at, :datetime
    add_column :users, :uncrypted_password, :string
  end
end
