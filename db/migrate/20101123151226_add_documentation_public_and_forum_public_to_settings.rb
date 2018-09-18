class AddDocumentationPublicAndForumPublicToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :documentation_public, :boolean, :null => false, :default => false
    add_column :settings, :forum_public,         :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :settings, :forum_public
    remove_column :settings, :documentation_public
  end
end
