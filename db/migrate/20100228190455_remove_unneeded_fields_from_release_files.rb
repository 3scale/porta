class RemoveUnneededFieldsFromReleaseFiles < ActiveRecord::Migration
  def self.up
    remove_column :release_files, :published
    remove_column :release_files, :deleted
    remove_column :release_files, :archived

    remove_column :release_files, :created_by
    remove_column :release_files, :updated_by
    remove_column :release_files, :published_at
    remove_column :release_files, :state
  end

  def self.down
    add_column :release_files, :published, :boolean, :default => false
    add_column :release_files, :deleted, :boolean, :default => false
    add_column :release_files, :archived, :boolean, :default => false
    add_column :release_files, :created_by, :integer
    add_column :release_files, :updated_by, :integer
    add_column :release_files, :published_at, :datetime
    add_column :release_files, :state, :string, :default => "draft"
  end
end
