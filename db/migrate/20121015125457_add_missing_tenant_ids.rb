class AddMissingTenantIds < ActiveRecord::Migration
  def self.up
    # these are not meant to be used
    # they are just for mysqldump tool
    add_column :countries, :tenant_id, :integer
    add_column :schema_migrations, :tenant_id, :integer
    add_column :system_operations, :tenant_id, :integer
  end

  def self.down
    remove_column :countries, :tenant_id
    remove_column :schema_migrations, :tenant_id
    remove_column :system_operations, :tenant_id
  end
end
