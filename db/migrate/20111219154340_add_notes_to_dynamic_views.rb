class AddNotesToDynamicViews < ActiveRecord::Migration
  def self.up
    add_column :dynamic_views, :note, :string
    add_column :dynamic_view_versions, :note, :string
  end

  def self.down
    remove_column :dynamic_views, :note
    remove_column :dynamic_view_versions, :note
  end
end
