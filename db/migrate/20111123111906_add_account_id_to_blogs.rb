class AddAccountIdToBlogs < ActiveRecord::Migration
  def self.up
    add_column :blogs, :account_id, :integer
    add_index  :blogs, 'account_id'

    add_column :blog_versions, :account_id, :integer
    add_index  :blog_versions, 'account_id'
  end

  def self.down
    remove_column :blogs, :account_id
    remove_column :blog_versions, :account_id
  end
end
