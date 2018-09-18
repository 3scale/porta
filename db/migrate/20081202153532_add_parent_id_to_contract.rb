class AddParentIdToContract < ActiveRecord::Migration
  def self.up
    add_column :contracts, :parent_id, :integer
  end

  def self.down
    remove_column :contracts, :parent_id
  end
end
