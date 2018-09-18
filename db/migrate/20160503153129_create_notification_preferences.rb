class CreateNotificationPreferences < ActiveRecord::Migration
  def change
    create_table :notification_preferences do |t|
      t.references :user, index: { unique: true }, limit: 8
      t.binary :preferences

      t.timestamps
    end
  end
end
