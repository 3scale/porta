class DropSites < ActiveRecord::Migration
  def self.up
    drop_table :sites

    remove_column :forums, :site_id
    remove_column :topics, :site_id
    remove_column :posts,  :site_id
  end

  def self.down
    # Don't bother, it wasn't used anyway.
  end
end
