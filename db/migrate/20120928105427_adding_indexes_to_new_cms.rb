class AddingIndexesToNewCms < ActiveRecord::Migration
  def self.up
    add_index :cms_sections, :provider_id
    add_index :cms_sections, :parent_id
    add_index :cms_files, :section_id
    add_index :cms_files, [:provider_id, :path]
    add_index :cms_templates, :section_id
    add_index :cms_templates, [:provider_id, :path]
    add_index :cms_templates, [:provider_id, :system_name]
    add_index :cms_redirects, [:provider_id, :source]
  end

  def self.down
    remove_index :cms_sections, :provider_id
    remove_index :cms_sections, :parent_id
    remove_index :cms_files, :section_id
    remove_index :cms_files, [:provider_id, :path]
    remove_index :cms_templates, :section_id
    remove_index :cms_templates, [:provider_id, :path]
    remove_index :cms_templates, [:provider_id, :system_name]
    remove_index :cms_redirects, [:provider_id, :source]
 end
end
