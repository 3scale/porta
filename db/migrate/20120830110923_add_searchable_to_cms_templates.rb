class AddSearchableToCmsTemplates < ActiveRecord::Migration
  def self.up
    add_column :cms_templates, :searchable, :boolean, :default => false
    add_column :cms_templates_versions, :searchable, :boolean, :default => false
  end

  def self.down
    remove_column :cms_templates, :searchable
    remove_column :cms_templates_versions, :searchable
  end
end
