class AddCustomLinkToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :link_label, :string
    add_column :settings, :link_url, :string
  end

  def self.down
    remove_column :settings, :link_url
    remove_column :settings, :link_label
  end
end
