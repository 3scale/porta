class AddFieldsToForumPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :email, :string
    add_column :posts, :first_name, :string
    add_column :posts, :last_name, :string

    add_column :topics, :email, :string
    add_column :topics, :first_name, :string
    add_column :topics, :last_name, :string


    
  end

  def self.down
    remove_column :posts, :last_name
    remove_column :posts, :first_name
    remove_column :posts, :email

    remove_column :topics, :last_name
    remove_column :topics, :first_name
    remove_column :topics, :email
  end
end
