class AddMarkupToBcmsBlog < ActiveRecord::Migration

  def self.up
    add_column :blog_posts, :markup_type, :string, :default => 'simple'
    add_column :blog_posts, :content_with_markup, :string, :limit => 2147483647
    add_column :blog_post_versions, :markup_type, :string, :default => 'simple'
    add_column :blog_post_versions, :content_with_markup, :string, :limit => 2147483647
  end

  def self.down
    remove_column :blog_posts, :markup_type
    remove_column :blog_posts, :content_with_markup
    remove_column :blog_post_versions, :markup_type
    remove_column :blog_post_versions, :content_with_markup
  end
end
