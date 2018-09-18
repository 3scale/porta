class RemoveUserStamp < ActiveRecord::Migration
  def up
    remove_column :invitations, :creator_id
    remove_column :invitations, :updater_id
  end

  def down
    add_column :invitations, :integer, :creator_id, :limit => 8
    add_column :invitations, :integer, :updater_id, :limit => 8
  end
end
