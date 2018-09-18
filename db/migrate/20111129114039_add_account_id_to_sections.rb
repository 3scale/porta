class AddAccountIdToSections < ActiveRecord::Migration
  def self.up
    add_column :sections, :account_id, :integer
    add_index  :sections, 'account_id'

    add_column :section_nodes, :account_id, :integer
    add_index  :section_nodes, 'account_id'
  end

  def self.down
    remove_column :sections, :account_id
    remove_column :section_nodes, :account_id
  end
end
