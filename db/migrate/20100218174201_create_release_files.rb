class CreateReleaseFiles < ActiveRecord::Migration
  def self.up
    create_table :release_files do |t|
      t.string :name
      t.string :operating_systems
      t.string :architectures
      t.references :release

      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at

      t.boolean :deleted, :default => false
      t.boolean :published, :default => false
      t.boolean :archived, :default => false
      t.integer :created_by
      t.integer :updated_by
      t.string  :slug

      t.timestamps
    end
  end

  def self.down
    drop_table :release_files
  end
end
