class DroppingReleases < ActiveRecord::Migration
  def self.up
    drop_table :releases
    drop_table :release_files
    drop_table :downloads
    remove_column :settings, :downloads_enabled
  end

  def self.down
    create_table "releases", :force => true do |t|
      t.string   "name"
      t.string   "version"
      t.text     "notes"
      t.text     "quick_info"
      t.string   "state",        :default => "draft"
      t.datetime "expires_at"
      t.datetime "published_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "deleted",      :default => false
      t.boolean  "published",    :default => false
      t.boolean  "archived",     :default => false
      t.string   "slug"
    end

    create_table "release_files", :force => true do |t|
      t.string   "name"
      t.string   "operating_systems"
      t.string   "architectures"
      t.integer  "release_id"
      t.string   "attachment_file_name"
      t.string   "attachment_content_type"
      t.integer  "attachment_file_size"
      t.datetime "attachment_updated_at"
      t.string   "slug"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "downloads_count",         :default => 0
      t.string   "summary"
    end

    create_table "downloads", :force => true do |t|
      t.boolean  "downloaded",      :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "release_file_id"
      t.integer  "user_id"
      t.datetime "downloaded_at"
    end

    add_column :settings, :downloads_enabled, :boolean, :default => false
  end
end
