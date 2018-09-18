class AddingAccountIdToPortlets < ActiveRecord::Migration
  def self.up
    add_column :portlets, :account_id, :integer
    add_index  :portlets, 'account_id'
  end

  def self.down
    remove_column :portlets, :account_id
  end
end
