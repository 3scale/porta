class AddSecuredAtToUserSessions < ActiveRecord::Migration
  def change
    add_column :user_sessions, :secured_until, :timestamp
  end
end
