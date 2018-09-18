class BrowserCmsTables < ActiveRecord::Migration
  def self.up
    create_table "attachment_versions", :force => true do |t|
      t.integer  "attachment_id"
      t.integer  "version"
      t.string   "file_path"
      t.string   "file_location"
      t.string   "file_extension"
      t.string   "file_type"
      t.integer  "file_size"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.boolean  "published",       :default => false
      t.boolean  "deleted",         :default => false
      t.boolean  "archived",        :default => false
      t.string   "version_comment"
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
    end

    create_table "attachments", :force => true do |t|
      t.integer  "version"
      t.integer  "lock_version",   :default => 0
      t.string   "file_path"
      t.string   "file_location"
      t.string   "file_extension"
      t.string   "file_type"
      t.integer  "file_size"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.boolean  "published",      :default => false
      t.boolean  "deleted",        :default => false
      t.boolean  "archived",       :default => false
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
    end

    create_table "categories", :force => true do |t|
      t.integer  "category_type_id"
      t.integer  "parent_id"
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "category_types", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "connectors", :force => true do |t|
      t.integer  "page_id"
      t.integer  "page_version"
      t.integer  "connectable_id"
      t.string   "connectable_type"
      t.integer  "connectable_version"
      t.string   "container"
      t.integer  "position"
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
      t.integer  "content_type_group_id"
      t.integer  "priority",              :default => 2
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "dynamic_view_versions", :force => true do |t|
      t.integer  "dynamic_view_id"
      t.integer  "version"
      t.string   "type"
      t.string   "name"
      t.string   "format"
      t.string   "handler"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "published",       :default => false
      t.boolean  "deleted",         :default => false
      t.boolean  "archived",        :default => false
      t.string   "version_comment"
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
    end

    create_table "dynamic_views", :force => true do |t|
      t.integer  "version"
      t.integer  "lock_version",  :default => 0
      t.string   "type"
      t.string   "name"
      t.string   "format"
      t.string   "handler"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "published",     :default => false
      t.boolean  "deleted",       :default => false
      t.boolean  "archived",      :default => false
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
    end

    create_table "email_messages", :force => true do |t|
      t.string   "sender"
      t.text     "recipients"
      t.text     "subject"
      t.text     "cc"
      t.text     "bcc"
      t.text     "body"
      t.string   "content_type"
      t.datetime "delivered_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "file_block_versions", :force => true do |t|
      t.integer  "file_block_id"
      t.integer  "version"
      t.string   "type"
      t.string   "name"
      t.integer  "attachment_id"
      t.integer  "attachment_version"
      t.boolean  "published",          :default => false
      t.boolean  "deleted",            :default => false
      t.boolean  "archived",           :default => false
      t.string   "version_comment"
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "file_blocks", :force => true do |t|
      t.integer  "version"
      t.integer  "lock_version",       :default => 0
      t.string   "type"
      t.string   "name"
      t.integer  "attachment_id"
      t.integer  "attachment_version"
      t.boolean  "published",          :default => false
      t.boolean  "deleted",            :default => false
      t.boolean  "archived",           :default => false
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "group_permissions", :force => true do |t|
      t.integer "group_id"
      t.integer "permission_id"
    end

    create_table "group_sections", :force => true do |t|
      t.integer "group_id"
      t.integer "section_id"
    end

    create_table "group_type_permissions", :force => true do |t|
      t.integer "group_type_id"
      t.integer "permission_id"
    end

    create_table "group_types", :force => true do |t|
      t.string   "name"
      t.boolean  "guest",      :default => false
      t.boolean  "cms_access", :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "groups", :force => true do |t|
      t.string   "name"
      t.string   "code"
      t.integer  "group_type_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "html_block_versions", :force => true do |t|
      t.integer  "html_block_id"
      t.integer  "version"
      t.string   "name"
      t.string   "content",         :limit => 65537
      t.boolean  "published",                        :default => false
      t.boolean  "deleted",                          :default => false
      t.boolean  "archived",                         :default => false
      t.string   "version_comment"
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "html_blocks", :force => true do |t|
      t.integer  "version"
      t.integer  "lock_version",                   :default => 0
      t.string   "name"
      t.string   "content",       :limit => 65537
      t.boolean  "published",                      :default => false
      t.boolean  "deleted",                        :default => false
      t.boolean  "archived",                       :default => false
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "link_versions", :force => true do |t|
      t.integer  "link_id"
      t.integer  "version"
      t.string   "name"
      t.string   "url"
      t.boolean  "new_window",      :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "published",       :default => false
      t.boolean  "deleted",         :default => false
      t.boolean  "archived",        :default => false
      t.string   "version_comment"
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
    end

    create_table "links", :force => true do |t|
      t.integer  "version"
      t.integer  "lock_version",  :default => 0
      t.string   "name"
      t.string   "url"
      t.boolean  "new_window",    :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "published",     :default => false
      t.boolean  "deleted",       :default => false
      t.boolean  "archived",      :default => false
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
    end

    create_table "page_route_options", :force => true do |t|
      t.integer  "page_route_id"
      t.string   "type"
      t.string   "name"
      t.string   "value"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "page_routes", :force => true do |t|
      t.string   "name"
      t.string   "pattern"
      t.integer  "page_id"
      t.text     "code"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "page_versions", :force => true do |t|
      t.integer  "page_id"
      t.integer  "version"
      t.string   "name"
      t.string   "title"
      t.string   "path"
      t.string   "template_file_name"
      t.text     "description"
      t.text     "keywords"
      t.string   "language"
      t.boolean  "cacheable",          :default => false
      t.boolean  "hidden",             :default => false
      t.boolean  "published",          :default => false
      t.boolean  "deleted",            :default => false
      t.boolean  "archived",           :default => false
      t.string   "version_comment"
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "pages", :force => true do |t|
      t.integer  "version"
      t.integer  "lock_version",       :default => 0
      t.string   "name"
      t.string   "title"
      t.string   "path"
      t.string   "template_file_name"
      t.text     "description"
      t.text     "keywords"
      t.string   "language"
      t.boolean  "cacheable",          :default => false
      t.boolean  "hidden",             :default => false
      t.boolean  "published",          :default => false
      t.boolean  "deleted",            :default => false
      t.boolean  "archived",           :default => false
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "permissions", :force => true do |t|
      t.string   "name"
      t.string   "full_name"
      t.string   "description"
      t.string   "for_module"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "portlet_attributes", :force => true do |t|
      t.integer "portlet_id"
      t.string  "name"
      t.text    "value"
    end

    create_table "portlets", :force => true do |t|
      t.string   "type"
      t.string   "name"
      t.boolean  "archived",      :default => false
      t.boolean  "deleted",       :default => false
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "redirects", :force => true do |t|
      t.string   "from_path"
      t.string   "to_path"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "section_nodes", :force => true do |t|
      t.integer  "section_id"
      t.string   "node_type"
      t.integer  "node_id"
      t.integer  "position"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "sections", :force => true do |t|
      t.string   "name"
      t.string   "path"
      t.boolean  "root",       :default => false
      t.boolean  "hidden",     :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end


    create_table "taggings", :force => true do |t|
      t.integer  "tag_id"
      t.integer  "taggable_id"
      t.string   "taggable_type"
      t.integer  "taggable_version"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "tags", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "tasks", :force => true do |t|
      t.integer  "assigned_by_id"
      t.integer  "assigned_to_id"
      t.integer  "page_id"
      t.text     "comment"
      t.date     "due_date"
      t.datetime "completed_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "user_group_memberships", :force => true do |t|
      t.integer "user_id"
      t.integer "group_id"
    end

  end

  def self.down
    drop_table :attachment_versions
    drop_table :attachments
    drop_table :categories
    drop_table :category_types
    drop_table :connectors
    drop_table :content_type_groups
    drop_table :content_types
    drop_table :dynamic_view_versions
    drop_table :dynamic_views
    drop_table :email_messages
    drop_table :file_block_versions
    drop_table :file_blocks
    drop_table :group_permissions
    drop_table :group_sections
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
    drop_table :taggings
    drop_table :tags
    drop_table :tasks
    drop_table :user_group_memberships
  end
end
