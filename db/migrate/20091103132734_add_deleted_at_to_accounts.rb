class AddDeletedAtToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :deleted_at, :datetime
  end

  def self.down
    remove_column :accounts, :deleted_at
  end
end
