class AddOperationIdToMessage < ActiveRecord::Migration
  def self.up
    add_column :messages, :system_operation_id, :integer
  end

  def self.down
    remove_column :messages, :system_operation_id
  end
end
