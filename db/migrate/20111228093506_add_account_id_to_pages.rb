class AddAccountIdToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :account_id, :integer
  end

  def self.down
    remove_column :pages, :account_id
  end
end
