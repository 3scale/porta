class FixGroupSections < ActiveRecord::Migration
  def self.up
    drop_table :cms_group_sections
    rename_table :group_sections, :cms_group_sections
  end

  def self.down
    rename_table :cms_group_sections, :group_sections
    create_table "cms_group_sections", :force => true do |t|
      t.integer  "tenant_id",  :limit => 8
      t.integer  "group_id",   :limit => 8
      t.integer  "section_id", :limit => 8
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
