class AddCasServerUrlToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :cas_server_url, :string
  end

  def self.down
    remove_column :settings, :cas_server_url
  end
end
