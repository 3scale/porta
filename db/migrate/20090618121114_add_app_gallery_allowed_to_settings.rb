class AddAppGalleryAllowedToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :app_gallery_allowed, :boolean, :default => false
  end

  def self.down
    remove_column :settings, :app_gallery_allowed
  end
end
