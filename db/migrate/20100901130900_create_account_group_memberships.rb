class CreateAccountGroupMemberships < ActiveRecord::Migration
  def self.up
    create_table :account_group_memberships do |t|
      t.integer :account_id
      t.integer :group_id
    end
    add_index :account_group_memberships, 'account_id', :name => 'idx_account_id'
    add_index :account_group_memberships, 'group_id', :name => 'idx_group_id'
  end

  def self.down
    drop_table :account_group_memberships
  end
end
