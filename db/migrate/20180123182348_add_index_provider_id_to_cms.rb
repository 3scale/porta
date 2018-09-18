class AddIndexProviderIdToCMS < ActiveRecord::Migration
  def change
    add_index :cms_files, :provider_id, name: 'index_cms_files_on_provider_id'
    add_index :cms_group_sections, :group_id, name: 'index_cms_group_sections_on_group_id'
    add_index :cms_groups, :provider_id, name: 'index_cms_groups_on_provider_id'
    add_index :cms_permissions, :account_id, name: 'index_cms_permissions_on_account_id'
    add_index :cms_redirects, :provider_id, name: 'index_cms_redirects_on_provider_id'
    add_index :cms_templates, [:provider_id, :type], name: 'index_cms_templates_on_provider_id_type'
    add_index :cms_templates_versions, [:provider_id, :type], name: 'index_cms_templates_versions_on_provider_id_type'
  end
end
