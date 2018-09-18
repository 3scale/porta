class RemoveParentIdFromServices < ActiveRecord::Migration
  def self.up
    remove_column :services, :parent_id
  end

  def self.down
    add_column :services, :parent_id, :integer
  end
end
