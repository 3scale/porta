class RemovingTheNewsPortlets < ActiveRecord::Migration
  def self.up
    drop_table :news_article_versions
    drop_table :news_articles
    drop_table :news_posts
  end

  def self.down
    create_table "news_article_versions", :force => true do |t|
      t.integer  "news_article_id"
      t.integer  "version"
      t.string   "name"
      t.string   "slug"
      t.datetime "release_date"
      t.integer  "category_id"
      t.integer  "attachment_id"
      t.integer  "attachment_version"
      t.text     "summary"
      t.text     "body"
      t.boolean  "published",          :default => false
      t.boolean  "deleted",            :default => false
      t.boolean  "archived",           :default => false
      t.string   "version_comment"
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "news_articles", :force => true do |t|
      t.integer  "version"
      t.integer  "lock_version",       :default => 0
      t.string   "name"
      t.string   "slug"
      t.datetime "release_date"
      t.integer  "category_id"
      t.integer  "attachment_id"
      t.integer  "attachment_version"
      t.text     "summary"
      t.text     "body"
      t.boolean  "published",          :default => false
      t.boolean  "deleted",            :default => false
      t.boolean  "archived",           :default => false
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "news_posts", :force => true do |t|
      t.string   "title"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "type"
    end
  end
end
