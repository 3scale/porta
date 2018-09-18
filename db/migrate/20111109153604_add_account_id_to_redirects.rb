class AddAccountIdToRedirects < ActiveRecord::Migration
  def self.up
    add_column :redirects, :account_id, :integer
  end

  def self.down
    remove_column :redirects, :account_id
  end
end
