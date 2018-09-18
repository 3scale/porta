class DropCmsGroupsPermission < ActiveRecord::Migration
  def self.up
    drop_table :cms_groups_permissions
  end

  def self.down
    create_table :cms_groups_permissions do |t|
      t.integer :group_id
      t.integer :permission_id

      t.timestamps
    end

  end
end
