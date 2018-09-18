class AddingIndexes < ActiveRecord::Migration
  def self.up
    add_index :dynamic_view_versions, :dynamic_view_id
    add_index :attachment_versions, :attachment_id
    add_index :file_block_versions, :file_block_id
    remove_index :section_nodes, :name => 'idx_node_type'
    remove_index :message_recipients, :name => 'idx_message_id'
    remove_index :plans, [:issuer_type, :issuer_id]
    remove_index :plans, :issuer_type
    remove_index :accounts, :name => 'idx_state'
    add_index :content_types, :content_type_group_id
    add_index :fields_definitions, :account_id
    add_index :metrics, :service_id
  end

  def self.down
    remove_index :dynamic_view_versions, :dynamic_view_id
    remove_index :attachment_versions, :attachment_id
    remove_index :file_block_versions, :file_block_id
    add_index :section_nodes, :node_type, :name => 'idx_node_type'
    add_index :message_recipients, :message_id, :name => 'idx_message_id'
    add_index :plans, [:issuer_type, :issuer_id]
    add_index :plans, :issuer_type
    add_index :accounts, :state, :name => 'idx_state'
    remove_index :content_types, :content_type_group_id
    remove_index :fields_definitions, :account_id
    remove_index :metrics, :service_id
  end
end
