class AddHeadersToDynamicViews < ActiveRecord::Migration
  def self.up
    add_column :dynamic_views, :headers, :text
    add_column :dynamic_view_versions, :headers, :text
  end

  def self.down
    remove_column :dynamic_views, :headers
    remove_column :dynamic_view_versions, :headers
  end
end
