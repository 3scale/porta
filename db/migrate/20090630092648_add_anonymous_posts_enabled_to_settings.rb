class AddAnonymousPostsEnabledToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :anonymous_posts_enabled, :boolean, :default => false
  end

  def self.down
    remove_column :settings, :anonymous_posts_enabled
  end
end
