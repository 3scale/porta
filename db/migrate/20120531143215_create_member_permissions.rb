class CreateMemberPermissions < ActiveRecord::Migration
  def self.up
    create_table :member_permissions do |t|
      t.integer :user_id, :limit => 8
      t.string  :admin_section
      t.timestamps
    end
  end

  def self.down
    drop_table :member_permissions
  end
end
