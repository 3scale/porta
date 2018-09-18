class RemoveToggleScreenshotFromSettings < ActiveRecord::Migration
  def up
    remove_column :settings, :toggle_screencast
  end

  def down
    add_column :settings, :toggle_screencast, :boolean
  end
end
