class MessageSenderIsNotPolymorphic < ActiveRecord::Migration
  def up
    remove_column :messages, :sender_type
    rename_index  :messages, 'index_messages_on_sender_id_and_sender_type_and_hidden_at', 'index_messages_on_sender_id_and_hidden_at'
  end

  def down
    add_column   :messages, :sender_type, :string, default: ''
    remove_index :messages, name: 'index_messages_on_sender_id_and_hidden_at'
    add_index    :messages, [:sender_id, :sender_type, :hidden_at]

    Message.update_all(sender_type: 'Account')
  end
end
