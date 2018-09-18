class AddTenantIdToMemberPermissions < ActiveRecord::Migration
  def self.up
    add_column :member_permissions, :tenant_id, :integer, :limit => 8
  end

  def self.down
    remove_column :member_permissions, :tenant_id
  end
end
