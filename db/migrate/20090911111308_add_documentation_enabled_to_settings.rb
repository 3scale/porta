class AddDocumentationEnabledToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :documentation_enabled, :boolean, :default => true
  end

  def self.down
    remove_column :settings, :documentation_enabled
  end
end
