class CmsStreams < ActiveRecord::Migration
  def self.up
    create_table :streams do |t|
      t.string :name
      t.string :slug
      t.belongs_to :attachment
      t.integer :attachment_version
      t.text :body, :size => (64.kilobytes + 1)
      t.belongs_to :category
      t.belongs_to :tag
      t.integer :version
      t.integer :lock_version, :default => 0
      t.boolean :published, :default => false
      t.boolean :deleted, :default => false
      t.boolean :archived, :default => false
      t.integer :created_by_id
      t.integer :updated_by_id
      t.timestamps
    end
    create_table :stream_versions do |t|
      t.integer :stream_id
      t.string :name
      t.string :slug
      t.belongs_to :attachment
      t.integer :attachment_version
      t.text :body, :size => (64.kilobytes + 1)
      t.belongs_to :category
      t.belongs_to :tag
      t.integer :version
      t.boolean :published, :default => false
      t.boolean :deleted, :default => false
      t.boolean :archived, :default => false
      t.integer :created_by_id
      t.integer :updated_by_id
      t.string :version_comment
      t.timestamps
    end
  end

  def self.down
    drop_table :stream_versions
    drop_table :streams
  end
end
