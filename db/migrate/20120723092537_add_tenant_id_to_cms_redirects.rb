class AddTenantIdToCmsRedirects < ActiveRecord::Migration
  def self.up
    add_column :cms_redirects, :tenant_id, :integer, :limit => 8
  end

  def self.down
    remove_column :cms_redirects, :tenant_id
  end
end
