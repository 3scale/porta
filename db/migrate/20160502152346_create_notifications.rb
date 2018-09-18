class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :user, index: true, limit: 8
      t.references :event, index: true, limit: 8
      t.string :system_name, limit: 1000
      t.string :state, limit: 20

      t.timestamps
    end
  end
end
