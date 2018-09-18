class AddIndexOnRedirects < ActiveRecord::Migration
  def self.up
    add_index :redirects, 'from_path', :name => 'idx_from_path'
  end

  def self.down
    remove_index :redirects, :name => 'idx_from_path'
  end
end
