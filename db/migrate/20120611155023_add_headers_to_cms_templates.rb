class AddHeadersToCmsTemplates < ActiveRecord::Migration
  def self.up
    add_column :cms_templates, :headers, :text
    add_column :cms_templates_versions, :headers, :text
  end

  def self.down
    remove_column :cms_templates, :headers
    remove_column :cms_templates_versions, :headers
  end
end
