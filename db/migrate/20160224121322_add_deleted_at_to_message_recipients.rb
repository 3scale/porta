class AddDeletedAtToMessageRecipients < ActiveRecord::Migration
  def change
    add_column :message_recipients, :deleted_at, :datetime
  end
end
