class AddUpdatedByToCmsTemplates < ActiveRecord::Migration
  def self.up
    add_column :cms_templates, :updated_by, :string
    add_column :cms_templates_versions, :updated_by, :string
  end

  def self.down
    remove_column :cms_templates, :updated_by
    remove_column :cms_templates_versions, :updated_by
  end
end
