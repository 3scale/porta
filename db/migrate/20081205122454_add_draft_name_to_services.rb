class AddDraftNameToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :draft_name, :string, :default => "", :null => false
  end

  def self.down
    remove_column :services, :draft_name
  end
end
