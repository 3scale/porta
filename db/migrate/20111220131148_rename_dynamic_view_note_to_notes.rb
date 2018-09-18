class RenameDynamicViewNoteToNotes < ActiveRecord::Migration
  def self.up
    rename_column :dynamic_views, :note, :notes
    rename_column :dynamic_view_versions, :note, :notes
  end

  def self.down
    rename_column :dynamic_views, :notes, :note
    rename_column :dynamic_view_versions, :notes, :note
   end
end
