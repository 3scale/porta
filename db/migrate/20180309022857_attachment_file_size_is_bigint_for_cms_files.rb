class AttachmentFileSizeIsBigintForCMSFiles < ActiveRecord::Migration
  def change
    change_column :cms_files, :attachment_file_size, :integer, limit: 8
  end
end
