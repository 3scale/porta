class ModifyCmsPermission < ActiveRecord::Migration
  def self.up
    add_column :cms_permissions, :group_id, :integer, :limit => 8
  end

  def self.down
    remove_column :cms_permissions, :group_id
  end
end
