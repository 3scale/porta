class TemplateIdIsBigintForCMSTemplatesVersions < ActiveRecord::Migration
  def change
    change_column :cms_templates_versions, :template_id, :integer, limit: 8
  end
end
