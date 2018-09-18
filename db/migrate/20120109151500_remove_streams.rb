class RemoveStreams < ActiveRecord::Migration
  def self.up
    drop_table :stream_versions
    drop_table :streams
  end

  def self.down
    create_table "stream_versions", :force => true do |t|
      t.integer  "stream_id"
      t.integer  "version"
      t.string   "name"
      t.string   "slug"
      t.integer  "attachment_id"
      t.integer  "attachment_version"
      t.text     "body"
      t.integer  "category_id"
      t.integer  "tag_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "published",          :default => false
      t.boolean  "deleted",            :default => false
      t.boolean  "archived",           :default => false
      t.string   "version_comment"
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
    end

    create_table "streams", :force => true do |t|
      t.integer  "version"
      t.integer  "lock_version",       :default => 0
      t.string   "name"
      t.string   "slug"
      t.integer  "attachment_id"
      t.integer  "attachment_version"
      t.text     "body"
      t.integer  "category_id"
      t.integer  "tag_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "published",          :default => false
      t.boolean  "deleted",            :default => false
      t.boolean  "archived",           :default => false
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
    end
  end
end
