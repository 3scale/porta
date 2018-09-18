class RenameCmsTemplateHeadersToOptions < ActiveRecord::Migration
  def self.up
    rename_column :cms_templates, :headers, :options
    rename_column :cms_templates_versions, :headers, :options
  end

  def self.down
    rename_column :cms_templates, :options, :headers
    rename_column :cms_templates_versions, :options, :headers
  end
end
