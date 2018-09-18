class AddAccountIdToBlogPosts < ActiveRecord::Migration
  def self.up
    add_column :blog_posts, :account_id, :integer
    add_index  :blog_posts, 'account_id'

    add_column :blog_post_versions, :account_id, :integer
    add_index  :blog_post_versions, 'account_id'
  end

  def self.down
    remove_column :blog_posts, :account_id
    remove_column :blog_post_versions, :account_id
  end
end
