class AddAcceptedAtToInvitations < ActiveRecord::Migration
  def self.up
    add_column :invitations, :accepted_at, :datetime
  end

  def self.down
    remove_column :invitations, :accepted_at
  end
end
