class AddUserIdToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :user_id, :integer, default: nil
  end
end
