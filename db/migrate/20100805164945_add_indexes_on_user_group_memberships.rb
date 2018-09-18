class AddIndexesOnUserGroupMemberships < ActiveRecord::Migration
  def self.up
    add_index :user_group_memberships, 'user_id', :name => 'idx_user_id'
    add_index :user_group_memberships, 'group_id', :name => 'idx_group_id'
  end

  def self.down
    remove_index :user_group_memberships, :name => 'idx_user_id'
    remove_index :user_group_memberships, :name => 'idx_group_id'
  end
end
