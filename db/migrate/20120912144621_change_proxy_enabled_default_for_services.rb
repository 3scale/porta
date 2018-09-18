class ChangeProxyEnabledDefaultForServices < ActiveRecord::Migration
  def self.up
    change_column :services, :proxy_enabled, :boolean, :default => false
  end

  def self.down
    change_column :services, :proxy_enabled, :string
  end

end
