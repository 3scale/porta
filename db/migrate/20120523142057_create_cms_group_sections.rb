class CreateCmsGroupSections < ActiveRecord::Migration
  def self.up
    create_table :cms_group_sections do |t|
      t.integer :tenant_id, :limit => 8
      t.integer :group_id, :limit => 8
      t.integer :section_id, :limit => 8

      t.timestamps
    end
  end

  def self.down
    drop_table :cms_group_sections
  end
end
