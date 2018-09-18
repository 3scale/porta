class CreateReleases < ActiveRecord::Migration
  def self.up
    create_table :releases do |t|
      # t.references :account_id
      t.string :name
      t.string :version
      t.text :notes
      t.text :quick_info
      t.string :state, :default => 'draft'
      t.datetime :expires_at
      t.datetime :published_at
      t.string :stream

      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :releases
  end
end
