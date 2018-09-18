class AddRailsViewPathToCmsTemplates < ActiveRecord::Migration
  def change
    add_column :cms_templates, :rails_view_path, :string
    add_index :cms_templates, [:provider_id, :rails_view_path]
  end
end
