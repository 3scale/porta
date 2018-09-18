class RenameBlogPostsToPosts < ActiveRecord::Migration
  def self.up
    rename_table 'blog_posts', 'posts'
  end

  def self.down
    rename_table 'posts', 'blog_posts'
  end
end
