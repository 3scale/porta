class RemovingBcmsTables < ActiveRecord::Migration
  def self.up
    drop_table :account_group_memberships
    drop_table :app_exhibits
    drop_table :assets
    drop_table :attachment_versions
    drop_table :attachments
    drop_table :blog_comment_versions
    drop_table :blog_comments
    drop_table :blog_group_membership_versions
    drop_table :blog_group_memberships
    drop_table :blog_post_versions
    drop_table :blog_posts
    drop_table :blog_versions
    drop_table :blogs
    drop_table :connectors
    drop_table :content_type_groups
    drop_table :content_types
    drop_table :dynamic_view_versions
    drop_table :dynamic_views
    drop_table :file_block_versions
    drop_table :file_blocks
    drop_table :group_permissions
    drop_table :group_type_permissions
    drop_table :group_types
    drop_table :groups
    drop_table :html_block_versions
    drop_table :html_blocks
    drop_table :link_versions
    drop_table :links
    drop_table :page_route_options
    drop_table :page_routes
    drop_table :page_versions
    drop_table :pages
    drop_table :permissions
    drop_table :portlet_attributes
    drop_table :portlets
    drop_table :redirects
    drop_table :section_nodes
    drop_table :sections
    drop_table :user_group_memberships
    drop_table :wiki_pages
  end

  def self.down
    create_table "account_group_memberships", :force => true do |t|
      t.integer "account_id", :limit => 8
      t.integer "group_id",   :limit => 8
      t.integer "tenant_id",  :limit => 8
    end
    add_index "account_group_memberships", ["account_id"], :name => "idx_account_id"
    add_index "account_group_memberships", ["group_id"], :name => "idx_group_id"
    create_table "app_exhibits", :force => true do |t|
      t.integer  "account_id",              :limit => 8
      t.string   "attachment_file_name"
      t.string   "attachment_content_type"
      t.integer  "attachment_file_size"
      t.string   "title"
      t.string   "url"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "position"
      t.integer  "tenant_id",               :limit => 8
    end
    create_table "assets", :force => true do |t|
      t.integer  "account_id",              :limit => 8
      t.string   "attachment_file_name"
      t.string   "attachment_content_type"
      t.integer  "attachment_file_size"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "tenant_id",               :limit => 8
    end
    create_table "attachment_versions", :force => true do |t|
      t.integer  "attachment_id",   :limit => 8
      t.integer  "version"
      t.string   "file_path"
      t.string   "file_location"
      t.string   "file_extension"
      t.string   "file_type"
      t.integer  "file_size"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.boolean  "published",                    :default => false
      t.boolean  "deleted",                      :default => false
      t.boolean  "archived",                     :default => false
      t.string   "version_comment"
      t.integer  "created_by_id",   :limit => 8
      t.integer  "updated_by_id",   :limit => 8
      t.integer  "account_id",      :limit => 8
      t.integer  "tenant_id",       :limit => 8
    end
    add_index "attachment_versions", ["account_id"], :name => "index_attachment_versions_on_account_id"
    add_index "attachment_versions", ["attachment_id"], :name => "index_attachment_versions_on_attachment_id"
    create_table "attachments", :force => true do |t|
      t.integer  "version"
      t.integer  "lock_version",                :default => 0
      t.string   "file_path"
      t.string   "file_location"
      t.string   "file_extension"
      t.string   "file_type"
      t.integer  "file_size"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.boolean  "published",                   :default => false
      t.boolean  "deleted",                     :default => false
      t.boolean  "archived",                    :default => false
      t.integer  "created_by_id",  :limit => 8
      t.integer  "updated_by_id",  :limit => 8
      t.integer  "account_id",     :limit => 8
      t.integer  "tenant_id",      :limit => 8
    end
    add_index "attachments", ["account_id"], :name => "index_attachments_on_account_id"
    create_table "blog_comment_versions", :force => true do |t|
      t.integer  "blog_comment_id", :limit => 8
      t.integer  "version"
      t.integer  "post_id",         :limit => 8
      t.string   "author"
      t.string   "email"
      t.string   "url"
      t.string   "ip"
      t.text     "body"
      t.string   "name"
      t.boolean  "published",                    :default => false
      t.boolean  "deleted",                      :default => false
      t.boolean  "archived",                     :default => false
      t.string   "version_comment"
      t.integer  "created_by_id",   :limit => 8
      t.integer  "updated_by_id",   :limit => 8
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "tenant_id",       :limit => 8
    end
    create_table "blog_comments", :force => true do |t|
      t.integer  "version"
      t.integer  "lock_version",               :default => 0
      t.integer  "post_id",       :limit => 8
      t.string   "author"
      t.string   "email"
      t.string   "url"
      t.string   "ip"
      t.text     "body"
      t.string   "name"
      t.boolean  "published",                  :default => false
      t.boolean  "deleted",                    :default => false
      t.boolean  "archived",                   :default => false
      t.integer  "created_by_id", :limit => 8
      t.integer  "updated_by_id", :limit => 8
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "tenant_id",     :limit => 8
    end
    create_table "blog_group_membership_versions", :force => true do |t|
      t.integer  "blog_group_membership_id", :limit => 8
      t.integer  "version"
      t.integer  "blog_id",                  :limit => 8
      t.integer  "group_id",                 :limit => 8
      t.string   "name"
      t.boolean  "published",                             :default => false
      t.boolean  "deleted",                               :default => false
      t.boolean  "archived",                              :default => false
      t.string   "version_comment"
      t.integer  "created_by_id",            :limit => 8
      t.integer  "updated_by_id",            :limit => 8
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "tenant_id",                :limit => 8
    end
    create_table "blog_group_memberships", :force => true do |t|
      t.integer  "version"
      t.integer  "lock_version",               :default => 0
      t.integer  "blog_id",       :limit => 8
      t.integer  "group_id",      :limit => 8
      t.string   "name"
      t.boolean  "published",                  :default => false
      t.boolean  "deleted",                    :default => false
      t.boolean  "archived",                   :default => false
      t.integer  "created_by_id", :limit => 8
      t.integer  "updated_by_id", :limit => 8
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "tenant_id",     :limit => 8
    end
    create_table "blog_post_versions", :force => true do |t|
      t.integer  "blog_post_id",        :limit => 8
      t.integer  "version"
      t.integer  "blog_id",             :limit => 8
      t.integer  "author_id",           :limit => 8
      t.integer  "category_id",         :limit => 8
      t.string   "name"
      t.string   "slug"
      t.text     "summary"
      t.text     "body"
      t.integer  "comments_count"
      t.datetime "published_at"
      t.boolean  "published",                                 :default => false
      t.boolean  "deleted",                                   :default => false
      t.boolean  "archived",                                  :default => false
      t.string   "version_comment"
      t.integer  "created_by_id",       :limit => 8
      t.integer  "updated_by_id",       :limit => 8
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "markup_type",                               :default => "simple"
      t.text     "content_with_markup", :limit => 2147483647
      t.integer  "account_id",          :limit => 8
      t.integer  "tenant_id",           :limit => 8
    end
    add_index "blog_post_versions", ["account_id"], :name => "index_blog_post_versions_on_account_id"
    create_table "blog_posts", :force => true do |t|
      t.integer  "version"
      t.integer  "lock_version",                              :default => 0
      t.integer  "blog_id",             :limit => 8
      t.integer  "author_id",           :limit => 8
      t.integer  "category_id",         :limit => 8
      t.string   "name"
      t.string   "slug"
      t.text     "summary"
      t.text     "body"
      t.integer  "comments_count"
      t.datetime "published_at"
      t.boolean  "published",                                 :default => false
      t.boolean  "deleted",                                   :default => false
      t.boolean  "archived",                                  :default => false
      t.integer  "created_by_id",       :limit => 8
      t.integer  "updated_by_id",       :limit => 8
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "markup_type",                               :default => "simple"
      t.text     "content_with_markup", :limit => 2147483647
      t.integer  "account_id",          :limit => 8
      t.integer  "tenant_id",           :limit => 8
    end
    add_index "blog_posts", ["account_id"], :name => "index_blog_posts_on_account_id"
    create_table "blog_versions", :force => true do |t|
      t.integer  "blog_id",         :limit => 8
      t.integer  "version"
      t.string   "name"
      t.string   "format"
      t.text     "template"
      t.boolean  "published",                    :default => false
      t.boolean  "deleted",                      :default => false
      t.boolean  "archived",                     :default => false
      t.string   "version_comment"
      t.integer  "created_by_id",   :limit => 8
      t.integer  "updated_by_id",   :limit => 8
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "account_id",      :limit => 8
      t.integer  "tenant_id",       :limit => 8
    end
    add_index "blog_versions", ["account_id"], :name => "index_blog_versions_on_account_id"
    create_table "blogs", :force => true do |t|
      t.integer  "version"
      t.integer  "lock_version",               :default => 0
      t.string   "name"
      t.string   "format"
      t.text     "template"
      t.boolean  "published",                  :default => false
      t.boolean  "deleted",                    :default => false
      t.boolean  "archived",                   :default => false
      t.integer  "created_by_id", :limit => 8
      t.integer  "updated_by_id", :limit => 8
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "account_id",    :limit => 8
      t.integer  "tenant_id",     :limit => 8
    end
    add_index "blogs", ["account_id"], :name => "index_blogs_on_account_id"
    create_table "connectors", :force => true do |t|
      t.integer  "page_id",             :limit => 8
      t.integer  "page_version"
      t.integer  "connectable_id",      :limit => 8
      t.string   "connectable_type",    :limit => 50
      t.integer  "connectable_version"
      t.string   "container"
      t.integer  "position"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "tenant_id",           :limit => 8
    end
    add_index "connectors", ["connectable_id"], :name => "index_connectors_on_connectable_id"
    add_index "connectors", ["container"], :name => "idx_container"
    add_index "connectors", ["page_id", "page_version", "connectable_id", "connectable_version", "connectable_type", "container"], :name => "unique_connector", :unique => true
    add_index "connectors", ["page_id"], :name => "idx_page_id"
    add_index "connectors", ["page_version"], :name => "idx_page_version"
    create_table "content_type_groups", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "content_type_groups", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "content_types", :force => true do |t|
      t.string   "name"
      t.integer  "content_type_group_id", :limit => 8
      t.integer  "priority",                           :default => 2
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "content_types", ["content_type_group_id"], :name => "index_content_types_on_content_type_group_id"
    create_table "dynamic_view_versions", :force => true do |t|
      t.integer  "dynamic_view_id", :limit => 8
      t.integer  "version"
      t.string   "type"
      t.string   "name"
      t.string   "format"
      t.string   "handler"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "published",                    :default => false
      t.boolean  "deleted",                      :default => false
      t.boolean  "archived",                     :default => false
      t.string   "version_comment"
      t.integer  "created_by_id",   :limit => 8
      t.integer  "updated_by_id",   :limit => 8
      t.integer  "account_id",      :limit => 8
      t.text     "headers"
      t.string   "notes"
      t.integer  "tenant_id",       :limit => 8
    end
    add_index "dynamic_view_versions", ["account_id"], :name => "index_dynamic_view_versions_on_account_id"
    add_index "dynamic_view_versions", ["dynamic_view_id"], :name => "index_dynamic_view_versions_on_dynamic_view_id"
    create_table "dynamic_views", :force => true do |t|
      t.integer  "version"
      t.integer  "lock_version",               :default => 0
      t.string   "type"
      t.string   "name"
      t.string   "format"
      t.string   "handler"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "published",                  :default => false
      t.boolean  "deleted",                    :default => false
      t.boolean  "archived",                   :default => false
      t.integer  "created_by_id", :limit => 8
      t.integer  "updated_by_id", :limit => 8
      t.integer  "account_id",    :limit => 8
      t.text     "headers"
      t.string   "notes"
      t.integer  "tenant_id",     :limit => 8
    end
    add_index "dynamic_views", ["account_id"], :name => "index_dynamic_views_on_account_id"
    create_table "file_block_versions", :force => true do |t|
      t.integer  "file_block_id",      :limit => 8
      t.integer  "version"
      t.string   "type"
      t.string   "name"
      t.integer  "attachment_id",      :limit => 8
      t.integer  "attachment_version"
      t.boolean  "published",                       :default => false
      t.boolean  "deleted",                         :default => false
      t.boolean  "archived",                        :default => false
      t.string   "version_comment"
      t.integer  "created_by_id",      :limit => 8
      t.integer  "updated_by_id",      :limit => 8
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "account_id",         :limit => 8
      t.integer  "tenant_id",          :limit => 8
    end
    add_index "file_block_versions", ["account_id"], :name => "index_file_block_versions_on_account_id"
    add_index "file_block_versions", ["file_block_id"], :name => "index_file_block_versions_on_file_block_id"
    create_table "file_blocks", :force => true do |t|
      t.integer  "version"
      t.integer  "lock_version",                    :default => 0
      t.string   "type"
      t.string   "name"
      t.integer  "attachment_id",      :limit => 8
      t.integer  "attachment_version"
      t.boolean  "published",                       :default => false
      t.boolean  "deleted",                         :default => false
      t.boolean  "archived",                        :default => false
      t.integer  "created_by_id",      :limit => 8
      t.integer  "updated_by_id",      :limit => 8
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "account_id",         :limit => 8
      t.integer  "tenant_id",          :limit => 8
    end
    add_index "file_blocks", ["account_id"], :name => "index_file_blocks_on_account_id"
    create_table "group_permissions", :force => true do |t|
      t.integer "group_id",      :limit => 8
      t.integer "permission_id", :limit => 8
      t.integer "tenant_id",     :limit => 8
    end
    create_table "group_type_permissions", :force => true do |t|
      t.integer "group_type_id", :limit => 8
      t.integer "permission_id", :limit => 8
    end
    create_table "group_types", :force => true do |t|
      t.string   "name"
      t.boolean  "guest",      :default => false
      t.boolean  "cms_access", :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "buyer",      :default => false
      t.boolean  "provider",   :default => true
    end
    create_table "groups", :force => true do |t|
      t.string   "name"
      t.string   "code"
      t.integer  "group_type_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "account_id",    :limit => 8
      t.integer  "tenant_id",     :limit => 8
    end
    add_index "groups", ["account_id"], :name => "index_groups_on_account_id"
    create_table "html_block_versions", :force => true do |t|
      t.integer  "html_block_id",       :limit => 8
      t.integer  "version"
      t.string   "name"
      t.text     "content",             :limit => 2147483647
      t.boolean  "published",                                 :default => false
      t.boolean  "deleted",                                   :default => false
      t.boolean  "archived",                                  :default => false
      t.string   "version_comment"
      t.integer  "created_by_id",       :limit => 8
      t.integer  "updated_by_id",       :limit => 8
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "markup_type",                               :default => "simple"
      t.text     "content_with_markup", :limit => 2147483647
      t.integer  "account_id",          :limit => 8
      t.integer  "tenant_id",           :limit => 8
    end
    add_index "html_block_versions", ["account_id"], :name => "index_html_block_versions_on_account_id"
    add_index "html_block_versions", ["html_block_id"], :name => "idx_html_block_id"
    add_index "html_block_versions", ["version"], :name => "idx_html_block_version"
    create_table "html_blocks", :force => true do |t|
      t.integer  "version"
      t.integer  "lock_version",                              :default => 0
      t.string   "name"
      t.text     "content",             :limit => 2147483647
      t.boolean  "published",                                 :default => false
      t.boolean  "deleted",                                   :default => false
      t.boolean  "archived",                                  :default => false
      t.integer  "created_by_id",       :limit => 8
      t.integer  "updated_by_id",       :limit => 8
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "markup_type",                               :default => "simple"
      t.text     "content_with_markup", :limit => 2147483647
      t.integer  "account_id",          :limit => 8
      t.integer  "tenant_id",           :limit => 8
    end
    add_index "html_blocks", ["account_id"], :name => "index_html_blocks_on_account_id"
    create_table "link_versions", :force => true do |t|
      t.integer  "link_id",         :limit => 8
      t.integer  "version"
      t.string   "name"
      t.string   "url"
      t.boolean  "new_window",                   :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "published",                    :default => false
      t.boolean  "deleted",                      :default => false
      t.boolean  "archived",                     :default => false
      t.string   "version_comment"
      t.integer  "created_by_id",   :limit => 8
      t.integer  "updated_by_id",   :limit => 8
      t.integer  "tenant_id",       :limit => 8
    end
    create_table "links", :force => true do |t|
      t.integer  "version"
      t.integer  "lock_version",               :default => 0
      t.string   "name"
      t.string   "url"
      t.boolean  "new_window",                 :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "published",                  :default => false
      t.boolean  "deleted",                    :default => false
      t.boolean  "archived",                   :default => false
      t.integer  "created_by_id", :limit => 8
      t.integer  "updated_by_id", :limit => 8
      t.integer  "account_id",    :limit => 8
      t.integer  "tenant_id",     :limit => 8
    end
    create_table "page_route_options", :force => true do |t|
      t.integer  "page_route_id", :limit => 8
      t.string   "type"
      t.string   "name"
      t.string   "value"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "tenant_id",     :limit => 8
    end
    create_table "page_routes", :force => true do |t|
      t.string   "name"
      t.string   "pattern"
      t.integer  "page_id",    :limit => 8
      t.text     "code"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "tenant_id",  :limit => 8
    end
    create_table "page_versions", :force => true do |t|
      t.integer  "page_id",            :limit => 8
      t.integer  "version"
      t.string   "name"
      t.string   "title"
      t.string   "path"
      t.string   "template_file_name"
      t.text     "description"
      t.text     "keywords"
      t.string   "language"
      t.boolean  "cacheable",                       :default => false
      t.boolean  "hidden",                          :default => false
      t.boolean  "published",                       :default => false
      t.boolean  "deleted",                         :default => false
      t.boolean  "archived",                        :default => false
      t.string   "version_comment"
      t.integer  "created_by_id",      :limit => 8
      t.integer  "updated_by_id",      :limit => 8
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "tenant_id",          :limit => 8
    end
    add_index "page_versions", ["page_id"], :name => "idx_page_id"
    add_index "page_versions", ["version"], :name => "idx_version"
    create_table "pages", :force => true do |t|
      t.integer  "version"
      t.integer  "lock_version",                    :default => 0
      t.string   "name"
      t.string   "title"
      t.string   "path"
      t.string   "template_file_name",              :default => "main_layout.liquid"
      t.text     "description"
      t.text     "keywords"
      t.string   "language"
      t.boolean  "cacheable",                       :default => false
      t.boolean  "hidden"
      t.boolean  "published",                       :default => false
      t.boolean  "deleted",                         :default => false
      t.boolean  "archived",                        :default => false
      t.integer  "created_by_id",      :limit => 8
      t.integer  "updated_by_id",      :limit => 8
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "account_id",         :limit => 8
      t.integer  "tenant_id",          :limit => 8
    end
    add_index "pages", ["deleted"], :name => "idx_deleted"
    create_table "permissions", :force => true do |t|
      t.string   "name"
      t.string   "full_name"
      t.string   "description"
      t.string   "for_module"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "portlet_attributes", :force => true do |t|
      t.integer "portlet_id", :limit => 8
      t.string  "name"
      t.text    "value"
      t.integer "tenant_id",  :limit => 8
    end
    create_table "portlets", :force => true do |t|
      t.string   "type"
      t.string   "name"
      t.boolean  "archived",                   :default => false
      t.boolean  "deleted",                    :default => false
      t.integer  "created_by_id", :limit => 8
      t.integer  "updated_by_id", :limit => 8
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "account_id",    :limit => 8
      t.integer  "tenant_id",     :limit => 8
    end
    add_index "portlets", ["account_id"], :name => "index_portlets_on_account_id"
    create_table "redirects", :force => true do |t|
      t.string   "from_path"
      t.string   "to_path"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "account_id", :limit => 8
      t.integer  "tenant_id",  :limit => 8
    end
    add_index "redirects", ["account_id"], :name => "index_redirects_on_account_id"
    add_index "redirects", ["from_path"], :name => "idx_from_path"
    create_table "section_nodes", :force => true do |t|
      t.integer  "section_id", :limit => 8
      t.string   "node_type"
      t.integer  "node_id",    :limit => 8
      t.integer  "position"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "account_id", :limit => 8
      t.integer  "tenant_id",  :limit => 8
    end
    add_index "section_nodes", ["account_id"], :name => "index_section_nodes_on_account_id"
    add_index "section_nodes", ["node_id"], :name => "idx_node_id"
    create_table "sections", :force => true do |t|
      t.string   "name"
      t.string   "path"
      t.boolean  "root",                           :default => false
      t.boolean  "hidden",                         :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "public",                         :default => false
      t.boolean  "restricted_access",              :default => false
      t.integer  "account_id",        :limit => 8
      t.integer  "tenant_id",         :limit => 8
    end
    add_index "sections", ["account_id"], :name => "index_sections_on_account_id"
    create_table "user_group_memberships", :force => true do |t|
      t.integer "user_id",   :limit => 8
      t.integer "group_id",  :limit => 8
      t.integer "tenant_id", :limit => 8
    end
    add_index "user_group_memberships", ["group_id"], :name => "idx_group_id"
    add_index "user_group_memberships", ["user_id"], :name => "idx_user_id"
    create_table "wiki_pages", :force => true do |t|
      t.integer  "account_id", :limit => 8
      t.string   "title"
      t.text     "content"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "position"
      t.integer  "tenant_id",  :limit => 8
    end
  end
end
