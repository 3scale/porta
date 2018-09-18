class RemoveMarkupTypeFromPosts < ActiveRecord::Migration
  def self.up
    remove_column :posts, :markup_type
  end

  def self.down
    add_column :posts, :markup_type, :string, :default => 'html'
  end
end
