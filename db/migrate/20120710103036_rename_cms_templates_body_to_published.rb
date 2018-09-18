class RenameCmsTemplatesBodyToPublished < ActiveRecord::Migration
  def self.up
    rename_column :cms_templates, :body, :published
    rename_column :cms_templates_versions, :body, :published
  end

  def self.down
    rename_column :cms_templates, :body, :published
    rename_column :cms_templates_versions, :body, :published
  end
end
