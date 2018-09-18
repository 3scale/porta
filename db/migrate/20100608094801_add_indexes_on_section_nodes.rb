class AddIndexesOnSectionNodes < ActiveRecord::Migration

  def self.up
    add_index :section_nodes, 'node_id', :name => 'idx_node_id'
    add_index :section_nodes, 'node_type', :name => 'idx_node_type'
  end

  def self.down
    remove_index :section_nodes, :name => 'idx_node_id'
    remove_index :section_nodes, :name => 'idx_node_type'
  end
end
