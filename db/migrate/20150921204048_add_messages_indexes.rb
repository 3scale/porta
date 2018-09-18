class AddMessagesIndexes < ActiveRecord::Migration
  def change
    add_index :messages, [:sender_id, :sender_type, :hidden_at]
  end
end
