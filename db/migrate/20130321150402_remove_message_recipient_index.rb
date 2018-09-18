class RemoveMessageRecipientIndex < ActiveRecord::Migration
  def up
    remove_index :message_recipients, name: "index_message_recipients_on_message_id_and_kind_and_position"
    add_index "message_recipients", [ "message_id", "kind" ]
  end

  def down
    remove_index "message_recipients", column: ["message_id", "kind" ]
    add_index "message_recipients", ["message_id", "kind", "position"], :name => "index_message_recipients_on_message_id_and_kind_and_position", :unique => true
  end
end
