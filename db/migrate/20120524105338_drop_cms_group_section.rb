class DropCmsGroupSection < ActiveRecord::Migration
  def self.up
    drop_table :cms_group_sections
  end

  def self.down
    create_table :cms_group_sections do |t|
      t.integer :tenant_id, :limit => 8
      t.integer :group_id, :limit => 8
      t.integer :section_id, :limit => 8

      t.timestamps
    end
  end

end
