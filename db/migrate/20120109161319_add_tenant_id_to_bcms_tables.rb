class AddTenantIdToBcmsTables < ActiveRecord::Migration
  def self.up
    add_column :account_group_memberships, :tenant_id, :integer
    add_column :attachment_versions, :tenant_id, :integer
    add_column :attachments, :tenant_id, :integer
    add_column :blog_comment_versions, :tenant_id, :integer
    add_column :blog_comments, :tenant_id, :integer
    add_column :blog_group_membership_versions, :tenant_id, :integer
    add_column :blog_group_memberships, :tenant_id, :integer
    add_column :blog_post_versions, :tenant_id, :integer
    add_column :blog_posts, :tenant_id, :integer
    add_column :blog_versions, :tenant_id, :integer
    add_column :blogs, :tenant_id, :integer
    add_column :categories, :tenant_id, :integer
    add_column :category_types, :tenant_id, :integer
    add_column :connectors, :tenant_id, :integer
    add_column :dynamic_view_versions, :tenant_id, :integer
    add_column :dynamic_views, :tenant_id, :integer
    add_column :file_block_versions, :tenant_id, :integer
    add_column :file_blocks, :tenant_id, :integer
    add_column :group_permissions, :tenant_id, :integer
    add_column :group_sections, :tenant_id, :integer
    add_column :groups, :tenant_id, :integer
    add_column :html_block_versions, :tenant_id, :integer
    add_column :html_blocks, :tenant_id, :integer
    add_column :link_versions, :tenant_id, :integer
    add_column :links, :tenant_id, :integer
    add_column :page_route_options, :tenant_id, :integer
    add_column :page_routes, :tenant_id, :integer
    add_column :page_versions, :tenant_id, :integer
    add_column :pages, :tenant_id, :integer
    add_column :portlet_attributes, :tenant_id, :integer
    add_column :portlets, :tenant_id, :integer
    add_column :redirects, :tenant_id, :integer
    add_column :section_nodes, :tenant_id, :integer
    add_column :sections, :tenant_id, :integer
    add_column :taggings, :tenant_id, :integer
    add_column :tags, :tenant_id, :integer
    add_column :user_group_memberships, :tenant_id, :integer
  end

  def self.down
    remove_column :account_group_memberships, :tenant_id
    remove_column :attachment_versions, :tenant_id
    remove_column :attachments, :tenant_id
    remove_column :blog_comment_versions, :tenant_id
    remove_column :blog_comments, :tenant_id
    remove_column :blog_group_membership_versions, :tenant_id
    remove_column :blog_group_memberships, :tenant_id
    remove_column :blog_post_versions, :tenant_id
    remove_column :blog_posts, :tenant_id
    remove_column :blog_versions, :tenant_id
    remove_column :blogs, :tenant_id
    remove_column :categories, :tenant_id
    remove_column :category_types, :tenant_id
    remove_column :connectors, :tenant_id
    remove_column :dynamic_view_versions, :tenant_id
    remove_column :dynamic_views, :tenant_id
    remove_column :file_block_versions, :tenant_id
    remove_column :file_blocks, :tenant_id
    remove_column :group_permissions, :tenant_id
    remove_column :group_sections, :tenant_id
    remove_column :groups, :tenant_id
    remove_column :html_block_versions, :tenant_id
    remove_column :html_blocks, :tenant_id
    remove_column :link_versions, :tenant_id
    remove_column :links, :tenant_id
    remove_column :page_route_options, :tenant_id
    remove_column :page_routes, :tenant_id
    remove_column :page_versions, :tenant_id
    remove_column :pages, :tenant_id
    remove_column :portlet_attributes, :tenant_id
    remove_column :portlets, :tenant_id
    remove_column :redirects, :tenant_id
    remove_column :section_nodes, :tenant_id
    remove_column :sections, :tenant_id
    remove_column :taggings, :tenant_id
    remove_column :tags, :tenant_id
    remove_column :user_group_memberships, :tenant_id
  end
end
