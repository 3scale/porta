class RemoveAttachmentFieldsFromReleases < ActiveRecord::Migration
  def self.up
    remove_column :releases, :attachment_file_name
    remove_column :releases, :attachment_content_type
    remove_column :releases, :attachment_file_size
    remove_column :releases, :attachment_updated_at
  end

  def self.down
    add_column :releases, :attachment_file_name, :string
    add_column :releases, :attachment_content_type, :string
    add_column :releases, :attachment_file_size, :integer
    add_column :releases, :attachment_updated_at, :datetime
  end
end
