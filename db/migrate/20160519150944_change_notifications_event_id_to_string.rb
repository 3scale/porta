class ChangeNotificationsEventIdToString < ActiveRecord::Migration

  def up
    Notification.delete_all
    change_column :notifications, :event_id, :string, null: false
  end

  def down
    change_column :notifications, :event_id, :integer, limit: 8
  end

end
