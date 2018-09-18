class AddAnonymousToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :anonymous_user, :boolean, :default => false
  end

  def self.down
    remove_column :posts, :anonymous_user
  end
end
