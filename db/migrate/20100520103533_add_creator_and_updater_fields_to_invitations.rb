class AddCreatorAndUpdaterFieldsToInvitations < ActiveRecord::Migration
  def self.up
    add_column :invitations, :creator_id, :integer
    add_column :invitations, :updater_id, :integer
  end

  def self.down
    remove_column :invitations, :creator_id
    remove_column :invitations, :updater_id
  end
end
