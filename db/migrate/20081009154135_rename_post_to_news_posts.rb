class RenamePostToNewsPosts < ActiveRecord::Migration
  def self.up
    rename_table :posts, :news_posts
  end

  def self.down
    rename_table :news_posts, :posts
  end
end
