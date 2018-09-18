class AddHandlerToCmsTemplates < ActiveRecord::Migration
  def self.up
    add_column :cms_templates, :handler, :string
    add_column :cms_templates_versions, :handler, :string
  end

  def self.down
    remove_column :cms_templates, :handler
    remove_column :cms_templates_versions, :handler
  end
end
