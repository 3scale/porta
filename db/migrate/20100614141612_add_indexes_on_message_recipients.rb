class AddIndexesOnMessageRecipients < ActiveRecord::Migration
  def self.up
    add_index :message_recipients, "message_id", :name => "idx_message_id"
    add_index :message_recipients, "receiver_id", :name => "idx_receiver_id"
  end

  def self.down
    remove_index :message_recipients, :name => "idx_message_id"
    remove_index :message_recipients, :name => "idx_receiver_id"
  end
end
