class AddServiceNotificationSettings < ActiveRecord::Migration
  def self.up
    change_table Service.table_name do |t|
      t.text :notification_settings
    end
  end

  def self.down
    change_table Service.table_name do |t|
      t.remove :notification_settings
    end
  end
end
