class CreateCmsGroupsPermissions < ActiveRecord::Migration
  def self.up
    create_table :cms_groups_permissions do |t|
      t.integer :group_id
      t.integer :permission_id

      t.timestamps
    end
  end

  def self.down
    drop_table :cms_groups_permissions
  end
end
