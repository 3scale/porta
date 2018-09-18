class AddLayoutIdToCmsTemplates < ActiveRecord::Migration
  def self.up
    add_column :cms_templates, :layout_id, :integer, :limit => 8
  end

  def self.down
    remove_column :cms_templates, :layout_id
  end
end
