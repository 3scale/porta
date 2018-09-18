class AddPosToSystemOperations < ActiveRecord::Migration
  def self.up
    add_column :system_operations, :pos, :integer
  end

  def self.down
    remove_column :system_operations, :pos
  end
end
