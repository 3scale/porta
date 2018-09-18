class MakeDownloadsLinkToUsersNotAccounts < ActiveRecord::Migration
  def self.up
    remove_column :downloads, :account_id
    add_column :downloads, :user_id, :integer
  end

  def self.down
    remove_column :downloads, :user_id
    add_column :downloads, :account_id, :integer
  end
end
