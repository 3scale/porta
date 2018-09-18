class AddLimitToInvitationsUserId < ActiveRecord::Migration
  def change
    change_column :invitations, :user_id, :integer, :limit => 8
  end
end
