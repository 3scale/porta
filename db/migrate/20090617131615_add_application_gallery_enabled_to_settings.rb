class AddApplicationGalleryEnabledToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :app_gallery_enabled, :boolean, :default => false
  end

  def self.down
    remove_column :settings, :app_gallery_enabled
  end
end
