class CmsFilesIdFieldsAreBigInts < ActiveRecord::Migration
  def self.up
    change_column :cms_files, :provider_id, :integer, :limit => 8
    change_column :cms_files, :section_id, :integer, :limit => 8
    change_column :cms_files, :tenant_id, :integer, :limit => 8
  end

  def self.down
    change_column :cms_files, :provider_id, :integer
    change_column :cms_files, :section_id, :integer
    change_column :cms_files, :tenant_id, :integer
  end
end
