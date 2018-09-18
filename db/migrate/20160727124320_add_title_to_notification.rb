class AddTitleToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :title, :string, limit: 1000
  end
end
