class AddMarkupTypeToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :markup_type, :string, :default => 'html'
  end

  def self.down
    remove_column :posts, :markup_type
  end
end
